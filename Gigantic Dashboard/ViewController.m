//
//  ViewController.m
//  Gigantic Dashboard
//
//  Created by Wai Man Chan on 1/5/15.
//
//

#import "ViewController.h"

NSTask *GiganticCentral, *GrammarEngine, *MoviePlugin, *VoiceUI;

@interface ViewController ()
@end

@implementation ViewController


- (NSTask *)taskWithName:(NSString *)name {
    NSString *address = [[NSBundle mainBundle] pathForAuxiliaryExecutable:name];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:address];
    return task;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    GiganticCentral = [self taskWithName:@"GiganticCentral"];
    GiganticCentral.standardInput = [NSPipe pipe];
    GrammarEngine = [self taskWithName:@"GrammarEngine"];
    MoviePlugin = [self taskWithName:@"MoviePlugin"];
    VoiceUI = [self taskWithName:@"VoiceUI"];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)viewWillDisappear {
    if (GiganticCentral.isRunning) [GiganticCentral terminate];
    if (GrammarEngine.isRunning) [GrammarEngine terminate];
    if (VoiceUI.isRunning) [VoiceUI terminate];
    if (MoviePlugin.isRunning) [MoviePlugin terminate];
    [super viewWillDisappear];
}

- (IBAction)toggle:(NSButton *)sender {
    NSTask *task = nil;
    switch (sender.tag) {
        case 0:
        task = GrammarEngine;
        break;
        case 1:
        task = GiganticCentral;
        break;
        case 2:
        task = VoiceUI;
        break;
        case 3:
        task = MoviePlugin;
        break;
    }
    if (task.isRunning) {
    } else {
        [task launch];
        sender.enabled = false;
    }
}

- (IBAction)trigger:(id)sender {
    [[(NSPipe *)(GiganticCentral.standardInput) fileHandleForWriting] writeData:[NSData dataWithBytes:"a" length:1]];
}

@end
