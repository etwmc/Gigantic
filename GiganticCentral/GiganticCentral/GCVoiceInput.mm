//
//  GCVoiceInput.cpp
//  GiganticCentral
//
//  Created by Wai Man Chan on 1/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCVoiceInput.h"

#import <julius/julius.h>

#import <AppKit/AppKit.h>

extern "C" {
    #import "GCRecording.h"
}

#import "PhaseConstruct.h"

#define printVoiceAnalyzeResult 0

#import "Configuration.h"

//Removed Old Code
//Used for: OS X internal voice recogition support
//Reason: Voice Recogition change to Julius
//Date: 23/Jan/2015
/*@class GCVoiceRecognizer;
//
//
//
//@protocol GCVoiceRecognizer <NSObject>
//- (void)speechRecognizer:(GCVoiceRecognizer *)sender didRecognizeTag:(NSString *)tag;
//@end
//
//@interface GCVoiceRecognizer : NSObject <NSSpeechRecognizerDelegate> {
//    NSSpeechRecognizer *recog;
//    NSDictionary *_tagList;
//    
//    WORD_INFO *wordList;
//}
//@property (readwrite) NSDictionary *tagList;
//@property (readwrite) NSObject <GCVoiceRecognizer> *delegate;
//@end
//
//@implementation GCVoiceRecognizer
//@synthesize delegate;
//
//- (NSDictionary *)tagList {
//    return _tagList;
//}
//- (void)setTagList:(NSDictionary *)tagList {
//    _tagList = tagList;
//    recog.commands = tagList.allKeys;
//}
//
//- (void)setCommands:(NSArray *)commands {
//    recog.commands = commands;
//    
//}
//
//- (id)init {
//    self = [super init];
//    if (self) {
//        recog = [NSSpeechRecognizer new];
//        recog.delegate = self;
//        wordList = word_info_new();
//    }
//    return self;
//}
//- (void)startListening { recog.startListening; }
//- (void)stopListening { recog.stopListening; }
//- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)command {
//    [delegate speechRecognizer:self didRecognizeTag:_tagList[command]];
//}
//
//- (void)dealloc { word_info_free(wordList); }
//
//@end
*/

@interface wordInfoWrapper : NSObject
@property (atomic, readwrite) WORD_INFO *info;
@end
@implementation wordInfoWrapper
@synthesize info;
- (void)dealloc
{
    if (info) word_info_free(info);
}
@end

@interface GCVoiceInputManager () <NSSpeechRecognizerDelegate> {
    Jconf *configuration;
    Recog *recognizer;
    
    NSMutableDictionary *wordsInfoList;
    
    dispatch_queue_t queue;
}
@end

void resultCallback(Recog *recog, void *data) {
    //NSLog(@"Got something");
    //Jconf *jconf = recog->jconf;
    WORD_INFO *winfo;
    WORD_ID *seq;
    int seqnum;
    int n;
    Sentence *s;
    RecogProcess *r;
    /* all recognition results are stored at each recognition process
     instance */
    for (r = recog->process_list; r; r = r->next) {
        
        /* skip the process if the process is not alive */
        if (!r->live)
            continue;
        
        /* result are in r->result.  See recog.h for details */
        
        /* check result status */
        if (r->result.status < 0) { /* no results obtained */
            /* outout message according to the status code */
            switch (r->result.status) {
                case J_RESULT_STATUS_REJECT_POWER:
                    printf("<input rejected by power>\n");
                    break;
                case J_RESULT_STATUS_TERMINATE:
                    printf("<input teminated by request>\n");
                    break;
                case J_RESULT_STATUS_ONLY_SILENCE:
                    printf("<input rejected by decoder (silence input result)>\n");
                    break;
                case J_RESULT_STATUS_REJECT_GMM:
                    printf("<input rejected by GMM>\n");
                    break;
                case J_RESULT_STATUS_REJECT_SHORT:
                    printf("<input rejected by short input>\n");
                    break;
                case J_RESULT_STATUS_FAIL:
                    printf("<search failed>\n");
                    break;
                case J_RESULT_STATUS_BUFFER_OVERFLOW:
                    printf("Buffer Overflow\n");
                    break;
            }
            /* continue to next process instance */
            continue;
        }
        
        /* output results for all the obtained sentences */
        winfo = r->lm->winfo;
        
        NSArray *array = @[];
        
        for (n = 0; n < r->result.sentnum; n++) { /* for all sentences */
            s = &(r->result.sent[n]);
            seq = s->word;
            seqnum = s->word_num;
            
            NSString *total = nil;
            for (int i = 0; i < seqnum; i++)
                if (strlen(winfo->woutput[seq[i]])) {
                    if (total.length)
                        total = [NSString stringWithFormat:@"%@ %s", total, winfo->woutput[seq[i]]];
                    else total = [NSString stringWithCString:winfo->woutput[seq[i]] encoding:NSUTF8StringEncoding];
                }
            
            
            
            total = total.lowercaseString;
#if printVoiceAnalyzeResult
            NSLog(@"%@ Confidence: %f", total, s->score);
#endif
            array = [array arrayByAddingObject:total];
            
            //printf(" %s", winfo->woutput[seq[i]]);
            //RecognizedAction::Invoke(gcnew RecogResult(uterrance, confidence));
            //Recognizer::OnRecognized(gcnew RecogResult(uterrance, confidence));
            //Recognizer::RecognizedActionDele::Invoke(gcnew RecogResult(uterrance, confidence));
        }
        
        [[phaseConstructor shareConstructor] addNewPhases:array];
        
    }
}

dispatch_semaphore_t pausingSemaphore = dispatch_semaphore_create(0);

void endSpeech(Recog *recog, void *data) {
    
}

void pausingCallback(Recog *recog, void *data) {
    dispatch_semaphore_wait(pausingSemaphore, DISPATCH_TIME_FOREVER);
}

@implementation GCVoiceInputManager

+ (instancetype)sharedManager {
#if TestMode == 1
    return nil;
#else
    static GCVoiceInputManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GCVoiceInputManager new];
    });
    return instance;
#endif
}

- (id)init {
    self = [super init];
    if (self) {
        
        wordsInfoList = [NSMutableDictionary dictionary];
        
        char configurationAddr[] = "/vui/Julius-4.2-Quickstart-Linux_AcousticModel-2015-01-14/Sample.jconf";
        
        configuration = j_config_load_file_new(configurationAddr);
        
        configuration->input.type = INPUT_WAVEFORM;
        configuration->input.speech_input = SP_MIC;
        configuration->input.device = SP_INPUT_DEFAULT;
        configuration->decodeopt.realtime_flag = FALSE;
        
        recognizer = j_create_instance_from_jconf(configuration);
        
        //Load a copy of core dictionary into a wrapper
        WORD_INFO *cornerStone = word_info_new();
        init_voca(cornerStone, configuration->lm_root->dictfilename, recognizer->amlist->hmminfo, true, false);
        wordInfoWrapper *cornerStoneWrapper = [wordInfoWrapper new];
        cornerStoneWrapper.info = cornerStone;
        
        [wordsInfoList setValue:cornerStoneWrapper forKey:@"Corner Stone"];
        
        callback_add(recognizer, CALLBACK_EVENT_SPEECH_STOP, &endSpeech, (__bridge void *)self);
        callback_add(recognizer, CALLBACK_PAUSE_FUNCTION, &pausingCallback, (__bridge void*)self);
        callback_add(recognizer, CALLBACK_RESULT, &resultCallback, (__bridge void *)self);
        j_adin_init(recognizer);
        
        queue = dispatch_queue_create("Voice Queue", DISPATCH_QUEUE_CONCURRENT);
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batchProcess:) name:@"Phase Construct Start" object:nil];
        
    }
    return self;
}

/* - (void)loadDictionary:(NSString *)dictionaryAddress
 * Function: Load the dictionary address into the engine
 * Parameter: dictionary address
 */
- (void)loadDictionary:(NSString *)dictionaryAddress {
    
    WORD_INFO *words = word_info_new();
    char filename[255]; strcpy(filename, dictionaryAddress.UTF8String);
    char sil[] = "sil";
    init_wordlist(words, filename, recognizer->lmlist->am->hmminfo, sil, sil, NULL, true);
    multigram_add_words_to_grammar(recognizer->lmlist, recognizer->lmlist->grammars, words);
    
}
- (void)loadExtensionDictionary:(NSString *)dictionaryAddress withID:(NSUInteger)extID {
    NSError *error;
    NSString *rawInput = [NSString stringWithContentsOfFile:dictionaryAddress encoding:NSUTF8StringEncoding error:&error];
    if (error) return;
    NSArray *inputs = [rawInput componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    WORD_INFO *winfo = word_info_new();
    char phone[] = "sil";
    voca_load_start(winfo, recognizer->lmlist->am->hmminfo, FALSE);
    
    for (NSString *obj in inputs) {
        if (obj.length != 0) {
            NSString *newString = [NSString stringWithFormat:obj, extID];
            char buffer[128];   strcpy(buffer, newString.UTF8String);
            voca_load_word_line(buffer, winfo, recognizer->lmlist->am->hmminfo, phone, phone, NULL);
        }
    }
    
    voca_load_end(winfo);
    
    wordInfoWrapper *wrapper = [wordInfoWrapper new];
    wrapper.info = winfo;
    
    [wordsInfoList setValue:wrapper forKey:[NSString stringWithFormat:@"%lu", (unsigned long)extID]];
    
    
    
    //bool ret = multigram_add_words_to_grammar(recognizer->lmlist, recognizer->lmlist->grammars, winfo);
    
    //Load the grammar again
    
    //bool ret = voca_append(recognizer->lmlist->winfo, winfo, recognizer->lmlist->grammars->id, recognizer->lmlist->grammars->winfo->num);
    
    //ret &= multigram_update(recognizer->lmlist);
    
    //ret &= j_final_fusion(recognizer);
}

- (void)startInput {
    //[coreRecog startListening];
    //[recoginzers.allValues makeObjectsPerformSelector:@selector(startListening)];
    //startRecording();
    if (recognizer->process_online) {
        dispatch_semaphore_signal(pausingSemaphore);
        //return;
    }
    j_request_resume(recognizer);
    
    //[self loadDictionary:@"/Users/waimanchan/Documents/Gigantic/GiganticCentral/GiganticCentral/Julius-4.2-Quickstart-Linux_AcousticModel-2015-01-08/grammar/sample1.dict"];
    
    switch (j_open_stream(recognizer, NULL)) {
        case 0: {
            dispatch_async(queue, ^{
                /**********************/
                /* Recognization Loop */
                /**********************/
                /* enter main loop to recognize the input stream */
                /* finish after whole input has been processed and input reaches end */
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                j_recognize_stream(recognizer);
                j_close_stream(recognizer);
//            }];
            });
                /*******/
                /* End */
                /*******/
                
                /* calling j_close_stream(recog) at any time will terminate
                 recognition and exit j_recognize_stream() */
                //SREngine::OnRecognition->Invoke(gcnew LapsAPI::RecoResult("FECHOU", 9));
                //FILE* f = jlog_get_fp();
                //fprintf(f, "sai");
                //jlog_flush();
            //});
        }
            break;
        case -1:
            NSLog(@"Error opening stream");
            break;
        case 2:
            NSLog(@"Failed to open stream");
            break;
            
    }
}

-(void)stopInput {
    //[coreRecog stopListening];
    //[recoginzers.allValues makeObjectsPerformSelector:@selector(stopListening)];
    //stopRecording();
    //j_request_terminate(recognizer);
}

/*
- (void)addNewWords:(NSDictionary *)configurationList withName:(NSString *)className {
    return;
    NSNumber *setID = configurationList[@"classID"];
    NSMutableDictionary *commands = [NSMutableDictionary dictionary];
    
    //Extract Noun
    {
        NSDictionary *list = configurationList[@"Noun"];
        NSArray *keys = list.allKeys;
        dispatch_apply(keys.count, queue, ^(size_t i) {
            NSString *key = keys[i];
            NSString *tagPhase = [NSString stringWithFormat:@"%@_n%zu", setID, i];
            [commands setObject:tagPhase forKey:key];
        });
    }
    
    //Extract Adjective
    {
        NSDictionary *list = configurationList[@"Adjective"];
        NSArray *keys = list.allKeys;
        dispatch_apply(keys.count, queue, ^(size_t i) {
            NSString *tagPhase = [NSString stringWithFormat:@"%@_a%zu", setID, i];
            [commands setObject:tagPhase forKey:keys[i]];
        });
    }
    
    //Extract Verb
    {
        NSDictionary *list = configurationList[@"Verb"];
        NSArray *keys = list.allKeys;
        dispatch_apply(keys.count, queue, ^(size_t i) {
            NSString *tagPhase = [NSString stringWithFormat:@"%@_v%zu", setID, i];
            [commands setObject:tagPhase forKey:keys[i]];
        });
    }
    
    //Extract Instance
    {
        NSDictionary *list = configurationList[@"instance"];
        NSArray *keys = list.allKeys;
        dispatch_apply(keys.count, queue, ^(size_t i) {
            NSString *tagPhase = [NSString stringWithFormat:@"%@_i%zu", setID, i];
            [commands setObject:tagPhase forKey:keys[i]];
        });
    }
    
    if (commands.count == 0) return;
    //GCVoiceRecognizer *recog = [GCVoiceRecognizer new];
    //recog.tagList = commands;
    //recog.delegate = self;
    
    //[recoginzers setObject:recog forKey:setID];
}
*/


//Removed Old Code
//Used for: OS X internal voice recogition delegate support
//Reason: Voice Recogition change to Julius
//Date: 23/Jan/2015
/*
- (void)batchProcess:(id)sender {
    [self stopInput];
    NSString *results = [array componentsJoinedByString:@" "];
    [array removeAllObjects];
}

- (void)tick {
    static NSTimer *timer = NULL;
    if (timer != NULL) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(batchProcess:) userInfo:nil repeats:NO];
}
- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)command {
    NSLog(@"%@", command);
    [array addObject:command];
    [self tick];
}

- (void)speechRecognizer:(GCVoiceRecognizer *)sender didRecognizeTag:(NSString *)tag {
    NSLog(@"%@", tag);
    [array addObject:tag];
    [self tick];
}
*/
@end