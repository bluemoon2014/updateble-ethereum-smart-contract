import "Strings.sol";

library StrMapping {
    
    using Strings for *;    
    
    /* 存json的结构定义 */
    /* 让value和所在位置一起存储， 便于遍历 */
    struct PosValue { uint keypos; string value; }
    struct KeyFlag { string key; bool deleted; }
    struct StrMap
    {
        mapping(string => PosValue) data;
        KeyFlag[] keys;
        uint size;
    }
    
    /* 插入一个 "key":"value" */
    function insert(StrMap storage self, string key, string value) internal returns (bool replaced)
    {
        uint keypos = self.data[key].keypos;
        self.data[key].value = value;
        if (keypos > 0)
            return true;
        else
        {
            keypos = self.keys.length++;
            self.data[key].keypos = keypos + 1;
            self.keys[keypos].key = key;
            self.size++;
            return false;
        }
    }
    /* 根据key删除一个键值对 */
    function remove(StrMap storage self, string key) internal returns (bool success)
    {
        uint keypos = self.data[key].keypos;
        if (keypos == 0)
        return false;
        delete self.data[key];
        self.keys[keypos - 1].deleted = true;
        self.size --;
    }
    
    /* 普通mapping不能遍历 下面方法是为了遍历一个map */
    function contains(StrMap storage self, string key) internal returns (bool)
    {
        return self.data[key].keypos > 0;
    }
    function strmap_start(StrMap storage self) internal returns (uint keypos)
    {
        return strmap_next(self, uint(-1));
    }
    function strmap_valid(StrMap storage self,uint keypos) internal returns (bool)
    {
        return keypos < self.keys.length;
    }
    function strmap_keylen(StrMap storage self) internal returns(uint keylen) {
        keylen = self.keys.length;
    }
    function strmap_next(StrMap storage self, uint keypos) internal returns (uint r_keypos)
    {
        keypos++;
        while (keypos < self.keys.length && self.keys[keypos].deleted)
        keypos++;
        return keypos;
    }

    function strmap_get(StrMap storage self,uint keypos) internal returns (string k, string v)
    {
        k = self.keys[keypos].key;
        v = self.data[k].value;
    }
    
    function clear(StrMap storage self) internal returns(bool) {
        for(uint i=0; i<self.keys.length; ++i) {
            string key = self.keys[i].key;
            if(bytes(key).length > 0 && !self.keys[i].deleted) {
                remove(self,key);
            }
        }
    }
    
}
