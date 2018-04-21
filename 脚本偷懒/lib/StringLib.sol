library StringLib{

    function _concatenate(string _a,string _b) constant internal returns (string ){
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        bytes memory c = new bytes(a.length+b.length);
        uint i;
        for(i=0;i<a.length;i++){
          c[i] = a[i];
        }
        for(uint j=0;j<b.length;j++){
          c[i+j] = b[j];
        }
        return string(c);
    }

    function _concat(string _a,string _b) constant internal returns (string ){
        return _concatenate(_a,_b);
    }

    function concat(string _a,string _b) constant returns (string ){
        return _concatenate(_a,_b);
    }


    function concatenate(string _a,string _b) constant public returns (string ){
        return _concatenate(_a,_b);
    }

    function _compare(string _a, string _b) constant internal returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }


    function compare(string _a, string _b) constant returns (int) {
        return _compare(_a,_b);
    }

    function _equal(string _a,string _b) constant internal returns (bool){
        return _compare(_a, _b) == 0;
    }

    function equal(string _a,string _b) constant returns (bool){
        return _equal(_a, _b);
    }


    function substring(string self,uint from,uint to) constant returns(string){
        return _substring(self,from,to);
    }

    function _substring(string self,uint from,uint to) constant internal returns(string){
        bytes memory data = bytes(self);
        return _substring(data,from,to);
    }

    function _substring(bytes self,uint from,uint to) constant internal returns(string){
        uint  size = to - from;
        bytes memory sub_str = new bytes(size);
        for(uint i=0;i<size;i++){
            sub_str[i] = self[i+from];
        }
        return string(sub_str);
    }

    function isEmpty(string self) constant returns(bool){
        return _isEmpty(self);
    }

    function _isEmpty(string self) constant internal returns(bool){
        return (bytes(self).length == 0);
    }

    function _startWith(string self,string _search) constant internal returns(bool){
        bytes memory data = bytes(self);
        bytes memory search_data = bytes(_search);
        if(search_data.length>data.length){
            return false;
        }
        string memory sub_data = substring(self,0,search_data.length);
        return sha3(sub_data) == sha3(_search);
    }

    function startWith(string self,string _search) constant returns(bool){
       return _startWith(self,_search);
    }

    function _getSplitCount(bytes _data,bytes1 _spliter) constant internal returns(uint){
        uint pos_begin = 0;
        uint splitCount = 0;
        for(uint i=0;i<_data.length;i++){
            bytes1 ch = _data[i];
            if( ch == _spliter ){
                if( i > pos_begin ){
                    splitCount++;
                }
                pos_begin = i+1;
            }
        }
        if( pos_begin < _data.length){
            splitCount++;
        }
        return splitCount;
    }


    function split(string _data,bytes1 _spliter) constant internal returns(string[] _result){
        bytes memory str_data = bytes(_data);
        uint count = _getSplitCount(str_data,_spliter);
        _result = new string[](count);
        uint pos_begin = 0;
        uint splitCount = 0;
        for(uint i=0;i<str_data.length;i++){
            bytes1 ch = str_data[i];
            if( ch == _spliter ){
                if( i > pos_begin ){
                    string memory subStr = _substring(str_data,pos_begin,i);
                    _result[splitCount] = subStr;
                    splitCount++;

                }
                pos_begin = i+1;
            }
        }
        if( pos_begin < str_data.length){
            subStr = _substring(str_data,pos_begin,i);
            _result[splitCount] = subStr;
            splitCount++;
        }
    }

    function memcpy(uint dest, uint src, uint len) private {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    struct StringBuffer{
        uint _buffLen;
        uint _ptr;
        uint _len;
    }

    function _malloc(StringBuffer self,uint _buffLen) constant internal returns(StringBuffer){
        uint _ptr;
        assembly{
            _ptr:= mload(0x40)
            mstore(0x40,add(_ptr,_buffLen))
        }
        self._ptr = _ptr;
        self._buffLen = _buffLen;
        self._len = 0;
        return self;
    }

    function _append(StringBuffer self,string _data) constant internal returns(StringBuffer){
        uint data_ptr;
        assembly {
            data_ptr := add(_data, 0x20)
        }
        uint data_len = bytes(_data).length;
        memcpy(self._ptr+self._len,data_ptr,data_len);
        self._len += data_len;
        return self;
    }

    function _toString(StringBuffer self) constant internal returns(string){
        var ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    function testStringBuffer() constant returns(string ){
        var buffer = StringBuffer(0,0,0);
        _malloc(buffer,10000);
        string memory s = "hello,";
        for(uint i=0;i<400;i++){
            _append(buffer,s);
        }
        return _toString(buffer);
    }

    function testConcat() constant returns(string){
        string memory s = "hello,";
        for(uint i=0;i<200;i++){
            s = _concat(s,s);
        }
        return s;
    }

    function testSplit(string _str,bytes1 _spliter) constant returns(uint _count,string _s1,string _s2,string _s3){
        var arrStr = split(_str,_spliter);
        _count = arrStr.length;
        _s1 = arrStr[0];
        _s2 = arrStr[1];
        _s3 = arrStr[2];

    }
    /*-------Json相关操作 开始----------*/
    function _appendJsonItem(StringBuffer _buffer,string _name,string _value) internal returns(StringBuffer){
        _append(_buffer,"\"");
        _append(_buffer,_name);
        _append(_buffer,"\":\"");
        _append(_buffer,_value);
        _append(_buffer,"\"");
        return _buffer;
    }

    function _appendJsonItem(StringBuffer _buffer,string _name,uint _value) internal returns(StringBuffer){
        _append(_buffer, "\"");
        _append(_buffer, _name);
        _append(_buffer, "\":");
        _append(_buffer, _toDecString(_value));
        return _buffer;
    }

    function _appendJsonObject(StringBuffer _buffer,string _name,string _value) internal returns(StringBuffer){
        _append(_buffer, "\"");
        _append(_buffer, _name);
        _append(_buffer, "\":");
        _append(_buffer, _value);
        return _buffer;
    }
    function _appendArrItem(StringBuffer _buffer,string iterm) internal returns(StringBuffer){
        _append(_buffer, "\"");
        _append(_buffer, iterm);
        _append(_buffer, "\"");
        return _buffer;
    }
    function _toDecString(uint data) constant private returns(string){
        if(data == 0){
            return "0";
        }
        uint base = 100000000000000000000000000000000000000000000000000000000000000;
        while( data/base < 1 ){
            base = base /10;
        }
        bytes1 b0= '0';
        string memory str="";
        bytes  memory str_n = new bytes(1);
        uint d = data;
        uint n;
        uint k=0;
        for(uint i=base; i>0; i=i/10){
            n = d/i;
            n = n & 0x0F;
            n = n + uint(b0);
            str_n[0] = bytes1(n) ;
            str = _concatenate(str, string(str_n) );
            d = d % i;
        }
        return str;
    }
    /*-------Json相关操作 结束----------*/
}
