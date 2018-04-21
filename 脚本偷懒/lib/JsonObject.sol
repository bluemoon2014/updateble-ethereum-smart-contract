import "Strings.sol";
import "StrMapping.sol";

library JsonObject {
    using Strings for *;
    using StrMapping for *;
    
    function insertKv(StrMapping.StrMap storage self, string k, string v) internal returns(bool) {
        return self.insert(k,v);
    }
    
    function get(StrMapping.StrMap storage self, string k) internal returns(string) {
        return self.data[k].value;
    }
        
    /**
     * @dev convert mapping to json
     * @param self iterated mapping
     * @param objFlg if value is an object objFlg=true
     */
    function stringTo(StrMapping.StrMap storage self, bool objFlg) internal returns(string js) {
        
        js = js.toSlice().concat("{".toSlice());
        for(uint i=0; self.strmap_valid(i); i=self.strmap_next(i)) {
    
            if(bytes(js).length > 1) {
                js = js.toSlice().concat(",".toSlice());
            }
            var (key, value) = self.strmap_get(i);
            if(key.toSlice().len() > 0) {
                js = js.toSlice().concat("\"".toSlice());
                js = js.toSlice().concat(key.toSlice());
                js = js.toSlice().concat("\"".toSlice());
                js = js.toSlice().concat(":".toSlice());
                if(!objFlg) {
                    js = js.toSlice().concat("\"".toSlice());
                }
                
                js = js.toSlice().concat(value.toSlice());
                if(!objFlg) {
                    js = js.toSlice().concat("\"".toSlice());
                }                
            }
        }
        js = js.toSlice().concat("}".toSlice());
    }
        
    /* 解析json字符串到 struct*/
    function parseJsn(StrMapping.StrMap storage self, string json) internal returns(bool) {
        //if(!validate(json))
        //    return false;
        
        /* 去掉大括号的内容 */
        var jsonSlice = json.toSlice();
        var s = jsonSlice.beyond("{".toSlice()).until("}".toSlice());
        var delim = ",".toSlice();
        var parts = new Strings.slice[](s.count(delim)+1);
        for(uint i = 0; i < parts.length; ++i) {
            if(s.contains(delim)) {
                parts[i] = s.split(delim);
            }
            else {
                parts[i] = s;
            }
            
            var item = parts[i].copy();
            var key = item.split(":".toSlice());
            key  = key.beyond("\"".toSlice()).until("\"".toSlice());
            
            if(item.contains("[".toSlice())) {
                item = item.beyond("[".toSlice()).until("]".toSlice());
            }
            else {
                item = item.beyond("\"".toSlice()).until("\"".toSlice());
            }
            self.insert(key.toString(), item.toString());
        }
        return true;		
    }
    
    /* 解析json字符串到 struct*/
    function parseJsnEx(StrMapping.StrMap storage self, string json) internal returns(bool) {
        //if(!validate(json))
        //    return false;
        
        /* 去掉大括号的内容 */
        var jsonSlice = json.toSlice();
        var s = jsonSlice.beyond("{".toSlice()).until("}".toSlice());
        var delim = ",".toSlice();
        var parts = new Strings.slice[](s.count(delim)+1);
        for(uint i = 0; i < parts.length; ++i) {
            if(s.contains(delim)) {
                parts[i] = s.split(delim);
            }
            else {
                parts[i] = s;
            }
            
            var item = parts[i].copy();
            var key = item.split(":".toSlice());
            key  = key.beyond("\'".toSlice()).until("\'".toSlice());
            item = item.beyond("\'".toSlice()).until("\'".toSlice());
            self.insert(key.toString(), item.toString());
        }
        return true;		
    }
    /* json合法性校验， 待补充*/
    function validate(string json) private returns(bool r) {
        Strings.slice memory jsonslice = json.toSlice();
        uint lbracecount = jsonslice.count("{".toSlice());
        uint rbracecount = jsonslice.count("}".toSlice());
        uint lbracketcount = jsonslice.count("[".toSlice());
        uint rbracketcount = jsonslice.count("]".toSlice());
        uint dquotcount = jsonslice.count("\"".toSlice());
        uint squotcount = jsonslice.count("\'".toSlice());
        r = (lbracecount==rbracecount) && (lbracketcount==rbracketcount);
        r = r && (dquotcount%2 == 0) && (squotcount%2 == 0);
    }
}
