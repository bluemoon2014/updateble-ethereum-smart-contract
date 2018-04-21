import "StringLib.sol";
import "ConvertLib.sol";

library JsonParseLib{
    using StringLib for string;
    using StringLib for bytes;
    using StringLib for StringLib.StringBuffer;
    enum ValueType {VT_STRING,VT_NUMBER,VT_BOOL}
    struct PraseResultItem{
        ValueType vt;
        uint level;
        int arrayIndex;
        string memberName;
        string value;
    }
    struct ParseResult{
        bool success;
        uint itemCount;
        PraseResultItem[] items;
    }
    struct ParseContext{
        uint _pos;
        bytes _json;
        uint _level;
        bool _arrayStatus;
        int _arrayIndex;
        ParseResult result;
    }

    //event Member(uint);
    event MatchedString(uint,uint,string);
    event MatchedObject(uint,uint,string);
    event MatchedArrayElement(uint,uint,int,string);

    function getItem(ParseResult self,string _memberName) internal returns(string _value){
        _value = "";
        for(uint i=0;i<self.itemCount;i++){
            if(self.items[i].memberName._equal(_memberName)){
                _value = self.items[i].value;
                break;
            }
        }
    }


    function jsonString(ParseContext ctx,string _memberName,string _value) internal{
        ParseResult memory result = ctx.result;
        if(!_memberName._equal("")){
            uint index = result.itemCount;
            PraseResultItem memory item = result.items[index];
            item.vt = ValueType.VT_STRING;
            item.level = ctx._level;
            item.arrayIndex = ctx._arrayIndex;
            item.memberName = _memberName;
            item.value = _value;
            result.itemCount++;
        }
    }
    function jsonNumber(ParseContext ctx,string _memberName,string _value) internal{
        ParseResult memory result = ctx.result;
        if(!_memberName._equal("")){
            uint index = result.itemCount;
            PraseResultItem memory item = result.items[index];
            item.vt = ValueType.VT_NUMBER;
            item.level = ctx._level;
            item.arrayIndex = ctx._arrayIndex;
            item.memberName = _memberName;
            item.value = _value;
            result.itemCount++;
        }
    }
    function jsonTrue(ParseContext ctx,string _memberName,string _value) internal{

    }

    function jsonFalse(ParseContext ctx,string _memberName,string _value) internal{
        
    }


    function _appendJsonItem(StringLib.StringBuffer _buffer,string _name,string _value) private returns(StringLib.StringBuffer){
        _buffer._append("\"")._append(_name)._append("\":\"")._append(_value)._append("\"");
        return _buffer;
    }

    function parseObject(string  _jsonString,uint _buffer) constant returns(string _json){
        ParseResult memory result = _parseObject(_jsonString,_buffer);
        StringLib.StringBuffer memory buffer = StringLib.StringBuffer(0,0,0);
        buffer._malloc(1000);
        buffer._append("{");
        string memory str_success = "false";
        if( result.success ){
            str_success = "true";
        }
        
        for(uint i=0;i<result.itemCount;i++){
            var item = result.items[i];
            _appendJsonItem(buffer,item.memberName,item.value)._append(",");
        }
        _appendJsonItem(buffer,"success",str_success);

        buffer._append("}");
        return buffer._toString();
    }

    function parseArray(string  _jsonString,uint _buffer) constant returns(string _json){
        ParseResult memory result = _parseArray(_jsonString,_buffer);
        StringLib.StringBuffer memory buffer = StringLib.StringBuffer(0,0,0);
        buffer._malloc(1000);
        buffer._append("[");

        
        string memory str_success = "false";
        if( result.success ){
            str_success = "true";
        }

        int arrayIndex = -1;
        
        for(uint i=0;i<result.itemCount;i++){
            var item = result.items[i];
            if(item.arrayIndex>arrayIndex){
                if(arrayIndex>=0){
                   buffer._append("},"); 
                }
                buffer._append("{");                
            }else if ( item.arrayIndex==arrayIndex ){
                buffer._append(",");  
            }
            _appendJsonItem(buffer,item.memberName,item.value);
            

            if(i == result.itemCount-1){
                buffer._append("}");
            }

            arrayIndex = item.arrayIndex;
        }
        buffer._append("]");
        return buffer._toString();
    }


    function _parseObject(string  _jsonString,uint _buffer) internal returns(ParseResult _result){
        //_pos = 0;
        bytes memory _json = bytes(_jsonString);
        ParseResult memory result =  ParseResult(false,0,new PraseResultItem[](_buffer));
        ParseContext memory ctx = ParseContext(0,_json,0,false,-1,result);
        ctx.result.success =  matchObject(ctx);
        _result = ctx.result;
    }

    function _parseArray(string _jsonString,uint _buffer) internal returns(ParseResult _result){
        bytes memory _json = bytes(_jsonString);
        ParseResult memory result =  ParseResult(false,0,new PraseResultItem[](_buffer));
        ParseContext memory ctx = ParseContext(0,_json,0,false,-1,result);
        var (m,v) =  matchArray(ctx,"");
        ctx.result.success = m;
        _result = ctx.result;
    }


    function matchObject(ParseContext ctx) private returns(bool){
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

    function matchMembers(ParseContext ctx) private returns(bool){
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

    function matchPair(ParseContext ctx) private returns(bool){
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

    function matchValue(ParseContext ctx,string _memberName) private  returns(bool,string){
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

    function matchNumber(ParseContext ctx,string _memberName) private returns(bool,string){
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



    function matchArray(ParseContext ctx,string _memberName) private returns(bool,string){
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

    function matchBracket(ParseContext ctx) private returns(bool){
        byte c = ctx._json[ctx._pos];
        if(c == '[' || c == ']'){
            ctx._pos++;
        }
        return true;
    }


    function matchComma(ParseContext ctx) private returns(bool){
        byte c = ctx._json[ctx._pos];
        if(c == ',' ){
            ctx._pos++;
        }
        return true;        
    }

    function matchString(ParseContext ctx,string _memberName) private  returns(bool,string){
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

    

    function matchBrace(ParseContext ctx) private  returns(bool){
        byte c = ctx._json[ctx._pos];
        if(c == '{' || c == '}'){
            ctx._pos++;
        }
        return true;
    }

    function matchColon(ParseContext ctx) private  returns(bool){
        if(ctx._json[ctx._pos] == ':' ){
            ctx._pos++;
        }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
        return true;
    }

    function matchSpace(ParseContext ctx) private  returns(bool){
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