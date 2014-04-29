%option noyywrap
%option case-insensitive
%{
#include "NLP.h"
#include "NLP.tab.h"
#include <stdio.h>
#include "helperFunction.h"
%}
/*Grammar*/
/*Verb*/
be		(is)|(are)|(am)
/*Noun*/
pronoun he|she|it|they|we|i|you
ownershipPronoun his|her|its|their|our|my|your
noun    time|date|day|name
/*Article*/
article a|an|the
/*Question Word*/
questionWord	(what)|(where)|(who)|(when)|(how)
ws		[ \t]+
/*Adjective*/
adjective full|first|last
/*Exclamation*/
exclamation hello|hi|bye|goodbye
%%
{questionWord}	{
    toLowerString(yytext);
    yylval.type = -1;
    if (yylval.type == -1) {matchString("when", yytext, qwtTime, yylval.type); }
    if (yylval.type == -1) {matchString("where", yytext, qwtLocation, yylval.type); }
    if (yylval.type == -1) {matchString("what", yytext, qwtGeneral, yylval.type); }
    if (yylval.type == -1) {matchString("who", yytext, qwtPerson, yylval.type); }
    yylval.raw = string(yytext);
    return QW;
}
{be}            {
    toLowerString(yytext);
    yylval.type = 0; yylval.raw = "be"; return VERB;
}
{noun}          {
    toLowerString(yytext);
    yylval.type = -1;
    /*Time*/
    if (yylval.type == -1) {matchString("time", yytext, ntTime, yylval.type); }
    if (yylval.type == -1) {matchString("date", yytext, ntDate, yylval.type); }
    if (yylval.type == -1) {matchString("day" , yytext, ntDate, yylval.type); }
    /*General Information*/
    if (yylval.type == -1) {matchString("name" , yytext, ntGeneral, yylval.type); }
    /*General Information*/
    if (yylval.type == -1) {
        yylval.type = ntGeneral;
    }
    yylval.raw = string(yytext);
    return NOUN;
}
{pronoun}       {
    toLowerString(yytext);
    /*
     * Pronoun should be an isolated group in the future, the relatedObj will be set at scanning
     */
    /*Pronoun*/
    if (yylval.type == -1) {matchString("i" , yytext, ntPronoun_I, yylval.type); }
    if (yylval.type == -1) {matchString("he" , yytext, ntPronoun_He, yylval.type); }
    if (yylval.type == -1) {matchString("she" , yytext, ntPronoun_She, yylval.type); }
    if (yylval.type == -1) {matchString("they" , yytext, ntPronoun_They, yylval.type); }
    if (yylval.type == -1) {matchString("we" , yytext, ntPronoun_We, yylval.type); }
    if (yylval.type == -1) {matchString("you" , yytext, ntPronoun_You, yylval.type); }
    yylval.raw = string(yytext);
    return PRONOUN;
}
{ownershipPronoun} {
    toLowerString(yytext);
    yylval.type = -1;
    if (yylval.type == -1) {matchString("his", yytext, 0, yylval.type); }
    if (yylval.type == -1) {matchString("her", yytext, 0, yylval.type); }
    if (yylval.type == -1) {matchString("its" , yytext, 0, yylval.type); }
    if (yylval.type == -1) {matchString("my", yytext, 0, yylval.type); }
    if (yylval.type == -1) {matchString("their", yytext, 0, yylval.type); }
    if (yylval.type == -1) {matchString("our" , yytext, 0, yylval.type); }
    if (yylval.type == -1) {matchString("your" , yytext, 0, yylval.type); }
    yylval.raw = string(yytext);
    return OWNERSHIP;
}
{adjective}     {
    toLowerString(yytext);
    yylval.type = atNetural;
    yylval.raw = string(yytext);
    return ADJECTIVE;
    
}
\n              { return *yytext; }
ws
.
%%
