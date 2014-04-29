%{
	#include "NLP.h"
	#include <stdio.h>
    #include <ctime>
    #include "Context.h"
#include "helperFunction.h"
    
	int yylex();
	int yyerror(const char*);
    %}
%token QW VERB NOUN Relation ADJECTIVE OWNERSHIP PRONOUN
%%
input	:
| input line;

line	: '\n'
| QUESTION '\n';

QUESTION: QT VERB NounPhase	{
    string answer;
    switch($1.type) {
        printf("%d", $1.type);
        case qwtTime:
        answer = returnCurrentTime();
        break;
        case qwtDate:
        answer = returnCurrentDate();
        break;
        //Where
        case qwtLocation: {
#warning - Not defined for people
            Person *per = dynamic_cast<Person *>($3.relatedObjs[0]);
            if (per) {
                string location = per->query("location");
                string locationTag = buildObjectOwnership(per, "location");
                if (location.compare("Unknown")==0) {
                    answer = buildSentence(locationTag, "be", simplePresent, false, "currently not available. ");
                } else if (location.compare("Checking")==0) {
                    answer = buildSentence($3.relatedObjs[0]->pronoun(), "check", simplePresent, false, locationTag);
                } else answer = buildSentence(per->query("pronoun") , "be", simplePresent, false, "in " + location);
            }
        }
        break;
        //Who
        case qwtPerson: {
            vector<Object *> objs = $3.relatedObjs;
            vector<Person *> people;
            for (vector<Object *>::iterator it = objs.begin(); it != objs.end(); it++) {
                Person *per = dynamic_cast<Person *>(*it);
                if (per) people.push_back(per);
            }
            switch (people.size()) {
                case 0:
                    answer = "I don't know who you are talking about";
                    break;
                case 1: {
                    string personNameString = buildObjectOwnership(people[0], "name");
                    answer = buildSentence(personNameString, "be", simplePresent, false, people[0]->query("name"));
                }
                    break;
                default:
                    break;
            }
	    }
	    break;
        case qwtGeneral: {
            bool newResult = false;
            vector<Object *> objs = $3.relatedObjs;
            for (vector<Object *>::iterator it = objs.begin(); it != objs.end(); it++) {
                string deltaResult = (*it)->query($3.raw, adjectiveConvertion($3.describe));
                string personNameString = constructNoun($3);
                personNameString = buildObjectOwnership((*it), personNameString);
                deltaResult = buildSentence(personNameString, "be", simplePresent, false, deltaResult);
                if (deltaResult.compare("")) {
                    if (newResult) answer = answer + "\n" + deltaResult;
                    else answer = deltaResult;
                    newResult = true;
                }
            }
        }
        break;
        default:
        printf("Question Word: \n");
    }
    printf("%s\n", answer.c_str());
} ;
/*Question Term = QT*/
QT:     QW NOUN     {
    if ($1.type == qwtGeneral) {
        char *ptr = new char[$1.raw.length()+$2.raw.length()+1];
        sprintf(ptr, "%s %s", $1.raw.c_str(), $2.raw.c_str());
        $$.raw = string(ptr);
        switch ($2.type) {
            case ntTime:
            $$.type = qwtTime;
            break;
            case ntDate:
            $$.type = qwtDate;
            break;
        }
    }
} | QW;
/*Linking relation of attibute*/
NounPhase: OWNERSHIP LinkedObj {
    $$ = $2;
    Context *context = Context::shareContext_InputSide();
    $$.relatedObjs = context->query($1.raw);
} |
PRONOUN {
    $$ = $1;
    Context *context = Context::shareContext_InputSide();
    $$.relatedObjs = context->query($1.raw);
}
| LinkedObj;
LinkedObj: ADJECTIVE NOUN {
    $2.describe.push_back($1);
    $$ = $2;
} | NOUN;
%%
int main () {
	return yyparse();
}
int yyerror (const char *s) {
	printf("Error: %s", s);
    return 0;
}
