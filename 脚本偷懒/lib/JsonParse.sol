import "StringLib.sol";

contract JsonParse{
    using StringLib for *;
    
    struct ParseContext{
        uint _pos;
        bytes _json;
        uint _level;
        bool _arrayStatus;
        int _arrayIndex;
    }

    //event Member(uint);
    event MatchedString(uint,uint,string);
    event MatchedObject(uint,uint,string);
    event MatchedArrayElement(uint,uint,int,string);


    function jsonString(ParseContext ctx,string _memberName,string _value) internal{

    }
    function jsonNumber(ParseContext ctx,string _memberName,string _value) internal{

    }
    function jsonTrue(ParseContext ctx,string _memberName,string _value) internal{

    }

    function jsonFalse(ParseContext ctx,string _memberName,string _value) internal{
        
    }


    function parse(string  _jsonString)  returns(bool _success){
        return parseObject(_jsonString);
    }

    function parseObject(string  _jsonString)  returns(bool _success){
        //_pos = 0;
        bytes memory _json = bytes(_jsonString);
        ParseContext memory ctx = ParseContext(0,_json,0,false,-1);
        return matchObject(ctx);
    }

    function parseArray(string _jsonString) returns(bool _success){
        bytes memory _json = bytes(_jsonString);
        ParseContext memory ctx = ParseContext(0,_json,0,false,-1);
        var (m,v) =  matchArray(ctx,"");
        return m;
    }


    function matchObject(ParseContext ctx) internal returns(bool){
        if( !matchBrace(ctx) ){
            return false;
        }
        if( !matchSpace(ctx) ){
            return false;
        }
        ctx._level++;
        if( !matchMembers(ctx) ){
            return false;
        }
        if( !matchBrace(ctx) ){
            return false;
        }
        ctx._level--;
        return true;
    }

    function matchMembers(ParseContext ctx) internal returns(bool){
        if( !matchSpace(ctx) ){
            return false;
        }
        
        if( !matchPair(ctx) ){
            return false;
        }
        byte c = ctx._json[ctx._pos];
        while(c==','){
            matchComma(ctx);
            if(!matchSpace(ctx)){
                return false;
            }
            if(!matchPair(ctx)){
                return false;
            }
            if(!matchSpace(ctx)){
                return false;
            }
            c = ctx._json[ctx._pos];
        }
        return true;
    }

    function matchPair(ParseContext ctx) internal returns(bool){
        if( !matchSpace(ctx) ){
            return false;
        }
        var (valueMatch,memberName) = matchString(ctx,"");
        if(!valueMatch){
            return false;
        }
        if( !matchSpace(ctx) ){
            return false;
        }
        if( !matchColon(ctx) ){
            return false;
        }
        if( !matchSpace(ctx) ){
            return false;
        }
        var (v,m) = matchValue(ctx,memberName);
        if( !v){
            return false;
        }
        if( !matchSpace(ctx) ){
            return false;
        }
        return true;
    }

    function matchValue(ParseContext ctx,string _memberName) internal  returns(bool,string){
        byte c = ctx._json[ctx._pos];
        if( c == '{') {
            uint start_obj = ctx._pos;
            bool rv = matchObject(ctx);
            uint end_obj = ctx._pos;
            MatchedObject(start_obj,end_obj,ctx._json._substring(start_obj,end_obj));
            return (rv,ctx._json._substring(start_obj,end_obj));
        }
        else if( c == '"' ){
            return matchString(ctx,_memberName);
        }else if( (c>='0' && c<='9') || c=='.' ){
            return matchNumber(ctx,_memberName);
        }else if( ctx._json._substring(ctx._pos,ctx._pos+4)._equal("true")  ){
            ctx._pos=ctx._pos+4;
            jsonTrue(ctx,_memberName,"true");
            return (true,"true");
        } else if( ctx._json._substring(ctx._pos,ctx._pos+5)._equal("false") ){
            ctx._pos=ctx._pos+5;
            jsonTrue(ctx,_memberName,"false");
            return (true,"false");
        }
        return (false,"");
    }

    function matchNumber(ParseContext ctx,string _memberName) internal returns(bool,string){
        uint str_begin = ctx._pos;
        uint str_end;
        byte c = ctx._json[ctx._pos];
        while ( (c>='0' && c<='9') || c=='.' ){
            ctx._pos++;
            c = ctx._json[ctx._pos];
        }
        string memory matchedNumber = ctx._json._substring(str_begin,ctx._pos);
        jsonNumber(ctx,_memberName,matchedNumber);
        return (true,matchedNumber);
    }



    function matchArray(ParseContext ctx,string _memberName) internal returns(bool,string){
        if(!matchBracket(ctx)){
            return (false,"");
        }
        ctx._arrayStatus = true;
        ctx._arrayIndex = 0;
        uint str_begin = ctx._pos;
        uint elem_begin = ctx._pos;
        var (m1,v1) = matchValue(ctx,_memberName);
        if(!m1){
            return (false,"");
        }
        uint elem_end = ctx._pos;
        string memory elem_str = ctx._json._substring(elem_begin,elem_end);
        MatchedArrayElement(elem_begin,elem_end,ctx._arrayIndex,elem_str);

        if(!matchSpace(ctx)){
            return (false,"");
        }
        byte c = ctx._json[ctx._pos];
        while(c==','){
            matchComma(ctx);
            ctx._arrayIndex++;
            elem_begin = ctx._pos;
            (m1,v1) = matchValue(ctx,_memberName);
            if(!m1){
                return (false,"");
            }
            elem_end = ctx._pos;
            elem_str = ctx._json._substring(elem_begin,elem_end);
            //MatchedArrayElement(elem_begin,elem_end,ctx._arrayIndex,elem_str);
            if(!matchSpace(ctx)){
            return (false,"");
            }
            c = ctx._json[ctx._pos];
        }
        if(!matchBracket(ctx)){
            return (false,"");
        }
        ctx._arrayStatus = false;
        ctx._arrayIndex = -1;
        string memory arrayString = ctx._json._substring(str_begin,ctx._pos);
        return (true,arrayString);
    }

    function matchBracket(ParseContext ctx) internal returns(bool){
        byte c = ctx._json[ctx._pos];
        if(c == '[' || c == ']'){
            ctx._pos++;
        }
        return true;
    }


    function matchComma(ParseContext ctx) internal returns(bool){
        byte c = ctx._json[ctx._pos];
        if(c == ',' ){
            ctx._pos++;
        }
        return true;        
    }

    function matchString(ParseContext ctx,string _memberName) internal  returns(bool,string){
        byte c = ctx._json[ctx._pos];
        uint str_begin;
        uint str_end;
        if(c == '"'){
            ctx._pos++;
            str_begin = ctx._pos;
        }else{
            return (false,"");
        }
        c = ctx._json[ctx._pos];
        while ( c != '"') {
            ctx._pos++;
            if(ctx._pos >= ctx._json.length){
                return (false,"");
            }
            c = ctx._json[ctx._pos];
        }
        string memory matchedString = ctx._json._substring(str_begin,ctx._pos);
        //MatchedString(str_begin,ctx._pos,matchedString);
        jsonString(ctx,_memberName,matchedString);
        ctx._pos++;
        return (true,matchedString);
    }

    

    function matchBrace(ParseContext ctx) internal  returns(bool){
        byte c = ctx._json[ctx._pos];
        if(c == '{' || c == '}'){
            ctx._pos++;
        }
        return true;
    }

    function matchColon(ParseContext ctx) internal  returns(bool){
        if(ctx._json[ctx._pos] == ':' ){
            ctx._pos++;
        }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
        return true;
    }

    function matchSpace(ParseContext ctx) internal  returns(bool){
        byte c = ctx._json[ctx._pos];
        while(c == ' ' || c == '\t' || c == '\n'){
            ctx._pos++;
            if(ctx._pos>=ctx._json.length){
                return false;
            }
            c = ctx._json[ctx._pos];
        }
        return true;
    }
    
}