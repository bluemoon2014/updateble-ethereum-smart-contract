import "JsonParse.sol";

contract JsonParseArray is JsonParse{
    using StringLib for string;

    struct Person{
        string _name;
        string _age;
    }

    Person[] persons;
    Person tmpPerson;

    mapping(string=>string[]) arrayData;

    int arrayIndex = -1;

    function parseArray(string _jsonString) returns(bool _success){
        //delete arrayData;
        delete arrayData["name"];
        delete arrayData["age"];
        bytes memory _json = bytes(_jsonString);
        ParseContext memory ctx = ParseContext(0,_json,0,false,-1);
        var (m,v) =  matchArray(ctx,"");
        return m;
    }

    function jsonString(ParseContext ctx,string _memberName,string _value) internal{
        if(_memberName.equal("name")){
            arrayData[_memberName].push(_value);
        }
        if(_memberName.equal("age")){
            arrayData[_memberName].push(_value);
        }
    }


    function makePerson(string _name,string _age) private returns(string ){
        string memory json = "{";
        return json._concat("\"name\"")._concat(":\"")._concat(_name)._concat("\"},")._concat("{\"age\":\"")._concat(_age)._concat("\"}");    
    }
    function dataToString() constant returns(string){
        string memory str = "[";
        string memory _name="";
        string memory _age="";
         // person;

        uint length = arrayData["name"].length;
        for(uint i=0;i<length;i++){
            
            _name = arrayData["name"][i];
            _age  = arrayData["age"][i];
           
            if(i==0){
                str=str._concat(makePerson(_name,_age));
            }else{
                str=str._concat(",")._concat(makePerson(_name,_age));
            }
            
        }
        return str._concatenate("]");
    }


}