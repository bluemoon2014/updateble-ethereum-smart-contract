#!/usr/bin/env node

var fs = require('fs');

//表名
//
var tableName;
//表字段数组
// var getFieldNamesFromTable(_tableName);

//表字段注释数组
// var getFieldCommentNamesFromTable(_tableName);

var inputName ;

var returnName;

var pKeyName;
//生成的四个文件名 
var fileNames = ["", "", "", ""];

var fileName = "Material";

//分隔符
var headerBegin = "\/\/TEMPLATE_HEADER";
var otherFunctionBegin = "\/\/TEMPLATE_OTHER_FUNCTION_BEGIN";
var otherFunctionEnd = "\/\/TEMPLATE_OTHER_FUNCTION_END";




//是否是定全部名字
var isAllNamed = false;

inputName = "_content"; returnName = "json_"; pKeyName = "_code";

// 表名
tableName = "MaterialInfo";
//表字段名
var fieldNames = ["iamOnlyOne","contractId","approveDate","approveStatus",
				"description","created","condParty","expectAmount","tempAmount","totalAmount"];

//表字段注释
var fieldCommentNames = ["审批代码","合同","批准日期","批准状态","描述","创建时间",
						"乙方","暂估金额","暂定金额","总金额"];

///初始化函数存储空间
//模板
///初始化函数存储空间
//模板
var addTemplate1 = "sizes[bytes4(sha3(\"ADD_FUNCTION(string)\"))]  = 32;";//bool string 
var addTemplate2 = "sizes[bytes4(sha3(\"QUERY_FUNCTION(string)\"))]  = uint32(SizeType.ST_STRING_3200);";//json string
var addTemplate3 = "sizes[bytes4(sha3(\"DEL_FUNCTION(string)\"))]  = uint32(SizeType.ST_NONE);";
var addTemplate4 = "";
//校验为空并更改的模板
var checkAndChangeTemplate = "if (needChange(NEW_STRUCT.FIELD_NAME)){\
\n\t\t	ORIGIN_STRUCT.FIELD_NAME = NEW_STRUCT.FIELD_NAME;\
\n\t\t}"

var checkIsStructDeletedTemplate = "if( !isStringEqual(ORIGIN_STRUCT.blockStatus, normal) )\
\n\t\treturn \"Already Deleted!\";";

var toJsonStringTemplate = "pairs.insert(\"FIELD_NAME\",ORIGIN_STRUCT.FIELD_NAME);";

//确保全部命名或者有指定模板名字
for (var i = 0; i < fileNames.length; i++) {
	if (isEmptyString(fileNames[i])) {
		mLog("文件名未指定，检查模板名字!");
		if(isEmptyString(fileName)) return 1;
		break;
	}
	isAllNamed = true;
}

var init_file_name = "init_tables.json";
var tableNamesJson;
var tableNamesArray;

parseAndGenerateAllTablesInfo( "./" + init_file_name);




function getFieldNamesFromTable(_tableName){
	return tableNamesJson[_tableName].fieldNames;
}

function getFieldCommentNamesFromTable(_tableName){
	return tableNamesJson[_tableName].fieldCommentNames;
}

//解析 json 并把相关表名 和 字段名等存入
function parseAndGenerateAllTablesInfo(_fileName){

	var tablesObjc = JSON.parse(fs.readFileSync(_fileName))

	tableNamesJson = tablesObjc;
	tableNamesArray = new Array();
	for (var key in tableNamesJson){
		tableNamesArray.push(key);
	}
}


//没有全部命名 生成模板名
if (!isAllNamed) {
	fileNames[0] = fileName + "Manage";
	fileNames[1] = fileNames[0] + "Impl";
	fileNames[2] = fileNames[0] + "Interface";
	fileNames[3] = fileNames[0] + "Storage";
}

writeManage();
writeInterface(tableName);
writeStorage(tableName);
writeImpl(tableName);

console.log(fs.readFileSync("./Gun.txt").toString());

//第0 manage 原样复制

function writeManage() {
	var stringToWrite = fs.readFileSync("./templateManage.sol").toString();
	//替换一个
	stringToWrite = stringToWrite.replace(/AuthManageStorage/g,fileNames[3]);
	stringToWrite = stringToWrite.replace(/AuthManage/g,fileNames[0]);

	fs.writeFileSync("./"+fileNames[0] +".sol",stringToWrite);
}

//第1 Impl  hard enough



function writeImpl(_tableName) {

	var stringToWrite = "";
	stringToWrite += formImplHeader();

	stringToWrite += "\/\/\/初始化函数存储空间\n\tfunction initialize(){\n\n";
	for (var i = 0; i < tableNamesArray.length; i++) {
		_tableName = tableNamesArray[i];
		stringToWrite += formImplInitia(_tableName);//产生初始化函数
	}
	//初始化函数的末尾
	stringToWrite += "\t}\n\n";
	stringToWrite += "\n";
	stringToWrite += formImplNoTableFunctionsAndVars();
	
	for (var i = 0; i < tableNamesArray.length; i++) {
		_tableName = tableNamesArray[i];
		stringToWrite += formImplTableFunctions(_tableName);
	}
	// 整个合约的结尾
	stringToWrite += "\n\n}\n\n\n\n";

	//write
	fs.writeFileSync("./" +fileNames[1] +".sol", stringToWrite);
}

//第2 interface 

function writeInterface(_tableName) {
	var stringToWrite = "\n\n\n";
	stringToWrite += "contract " +fileNames[2] + " {\n\n\n";

	for (var i = 0; i < tableNamesArray.length; i++) {
		_tableName = tableNamesArray[i];
		stringToWrite += geInterfaceForTable(_tableName);
		stringToWrite += "/\/\--------------------------" + _tableName +"--------------------------\n\n";
	}
	stringToWrite += "\n\n" +"    //-------定义事件---------------\n	event WriteSuccessEvent(string desc);\n\
	event WriteFailEvent(string desc);";
	stringToWrite += "\n\n" +"}" +"\n\n";

	fs.writeFileSync("./"+fileNames[2] +".sol", stringToWrite);
}

//第3 storage

function writeStorage(_tableName){
	var stringToWrite = "\n\n\n";
	stringToWrite += "contract " +fileNames[3] + " {\n\n\n";

	stringToWrite += "	string cancel = \"CANCEL\";\/\/无效状态\n	string normal = \"NORMAL\";\/\/有效状态\n\n";

	for (var i = 0; i < tableNamesArray.length; i++) {
		_tableName = tableNamesArray[i];
		stringToWrite += "	struct ";
		stringToWrite += _tableName +" {\n";
		stringToWrite += formStructFiledLine(_tableName);
		stringToWrite += "	}\n\n\n";
		stringToWrite += "	mapping (string => " + _tableName +") code2" +_tableName +";\n\n\n";
	}

	stringToWrite += "\n\n}\n\n";
	fs.writeFileSync("./" + fileNames[3] +".sol", stringToWrite);
}


//产生对应的表的方法实现 （四中)
function formImplTableFunctions(_tableName){

	var stringToReturn = "";
	stringToReturn += formAddFunctionImpl(_tableName);
	stringToReturn += formChangeFunctionImpl(_tableName);
	stringToReturn += formQueryFunctionImpl(_tableName);
	stringToReturn += formDelFunctionImpl(_tableName);

	return stringToReturn;
}

//产生增加的那个函数
function formAddFunctionImpl(_tableName){

	var stringToReturn = "";
	var fucPrototepe = "\t" + geAddInterface(formFunctionName(_tableName)[0]);
	stringToReturn += fucPrototepe + "{\n";
	
	//拿到解析生成结构体的新结构体名和代码
	var objt = formLinesOfNewStructFromDelimStr(_tableName)
	stringToReturn += objt.result;

	stringToReturn += formLinesOfOtherInfoAndStoreInBlockFromAddMethod(_tableName,objt.newStructName);

	stringToReturn += "\n\t}\n\n\n";
	return stringToReturn;
}
//产生更改的那个函数
function formChangeFunctionImpl(_tableName){
	
	var stringToReturn = "";
	var fucPrototepe = "\t" + geChangeInterface(formFunctionName(_tableName)[1]);
	stringToReturn += fucPrototepe + "{\n\n";

	//先产生解析数据的新结构体
	var objc = formLinesOfNewStructFromDelimStr(_tableName);
	stringToReturn += objc.result;
	stringToReturn += "\n\n";

	//产生一个原始的结构体
	//ContractInfo originCotrInfo = code2CotrInfo[cotrInfo.code];
	var originStructName = "origin" + toFirstUpper(objc.newStructName);
	stringToReturn += "\t\t" + _tableName +" "+ originStructName + " = " + formRetrieveStuctOfMapFromNewStruct(_tableName, objc.newStructName) +";";
	stringToReturn += "\n\n";

	//产生校验并更改
	stringToReturn += formLinesOfCheckAndChange(_tableName,objc.newStructName,originStructName);

	//产生剩下的事件 和 区块链的更改
	stringToReturn += "\n\n";
	stringToReturn += formLinesOfStoreInBlockAndEventFromChangeMethod(_tableName,objc.newStructName,originStructName);

	stringToReturn += "\n\t}\n\n\n";
	return stringToReturn;
}
//产生查询的那个函数
function formQueryFunctionImpl(_tableName){
	
	var stringToReturn = "";
	var fucPrototepe = "\t" + geQueryInterface(formFunctionName(_tableName)[2]);
	stringToReturn += fucPrototepe + "{\n";

	//产生一个原始的结构体
	//// ContractInfo originCotrInfo = code2CotrInfo[_code];
	var originStructName = "origin" + toFirstUpper(_tableName) + "Struct";

	stringToReturn += "\t\t" + _tableName + " " + originStructName + " = "
					 + formRetrieveStuctOfMapFromCode(_tableName) +";";

	stringToReturn += "\n\n";

//    var checkIsStructDeletedTemplate = "if( !isStringEqual(ORIGIN_STRUCT.blockStatus, normal) )\
// \n\t\treturn \"Already Deleted!\";";

	stringToReturn += "\t\t" + checkIsStructDeletedTemplate.replace(/ORIGIN_STRUCT/,originStructName);
	stringToReturn += "\n\n";
	
	stringToReturn += "\t\tpairs.clear();\n";
	//产生那些 形成JSON 字符串的 代码
	//var toJsonStringTemplate = "pairs.insert(\"FIELD_NAME\",ORIGIN_STRUCT.FIELD_NAME);";
	for (var i = 0; i < getFieldNamesFromTable(_tableName).length; i++) {
		var tempString = toJsonStringTemplate.replace(/FIELD_NAME/g,getFieldNamesFromTable(_tableName)[i]);
		tempString = tempString.replace(/ORIGIN_STRUCT/g,originStructName);
		stringToReturn += "\t\t" + tempString;
		stringToReturn += "\n";
	}
	stringToReturn += "\n\t\tjson_ = pairs.stringTo(false);\n";
	stringToReturn += "\t}\n\n\n";

	return stringToReturn;
}
//产生删除的那个函数
function formDelFunctionImpl(_tableName){
	
	var stringToReturn = "";
	var fucPrototepe = "\t" + geDelInterface(formFunctionName(_tableName)[3]);
	stringToReturn += fucPrototepe + "{\n";

	stringToReturn += "\n";

	var originStructName = "origin" + toFirstUpper(_tableName) + "Struct";
	stringToReturn += "\t\t" + _tableName + " " + originStructName +
					  " = " + formRetrieveStuctOfMapFromCode(_tableName) +";";
	stringToReturn += "\n";

	stringToReturn += "\t\t" + originStructName +".blockStatus = cancel;\n";
	stringToReturn += "\t\t" + originStructName +".lastModifyTime = now;\n";
	stringToReturn += "\t\t" + "WriteSuccessEvent(\"deleteSuccess\");";
	stringToReturn += "\n\n";
	stringToReturn += "\t}\n\n\n";

	 // ContractInfo originCotrInfo = code2CotrInfo[_code];
  //      originCotrInfo.blockStatus = cancel;
  //      originCotrInfo.lastModifyTime = now;


	return stringToReturn;
}

//产生剩下的事件 和 区块链的更改
function formLinesOfStoreInBlockAndEventFromChangeMethod(_tableName,_newStructName,_originStructName){

	  // originCotrInfo.lastModifyTime = now;

   //    code_ = cotrInfo.code;
   //    WriteSuccessEvent(code_);
     var stringToReturn = "";
     stringToReturn += "\t\t" + _originStructName + ".lastModifyTime = now;";
     stringToReturn += "\n";
     stringToReturn += "\t\t" + "code_ = " + _newStructName +"." + getFieldNamesFromTable(_tableName)[0] +";";
     stringToReturn += "\n";
     stringToReturn += "\t\tWriteSuccessEvent(code_);";

     stringToReturn += "\n\n";
     return stringToReturn;
}



//产生 校验传进来的参数是否为空 并更改的代码
//
function formLinesOfCheckAndChange(_tableName,_newStructName,_originStructName){

// var checkAndChangeTemplate = "if (needChange(NEW_STRUCT.FIELD_NAME)){\
// 	ORIGIN_STRUCT.FIELD_NAME = NEW_STRUCT.FIELD_NAME;\
// }"
  	var stringToReturn = "";
  	for (var i = 0; i < getFieldNamesFromTable(_tableName).length; i++) {
  		if (i == 0) continue;
  		var changedString = checkAndChangeTemplate.replace(/NEW_STRUCT/g,_newStructName);
  		changedString = changedString.replace(/FIELD_NAME/g,getFieldNamesFromTable(_tableName)[i]);
  		changedString = changedString.replace(/ORIGIN_STRUCT/g,_originStructName);

  		stringToReturn += "\t\t" + changedString;
  		stringToReturn += "\n\n";
  	}
  	return stringToReturn;
}


//产生 从传入的字符串分割解析出字段存入临时的结构体的代码
//返回一个对象{"newStructName" : newStructName,"result":stringToReturn}
function formLinesOfNewStructFromDelimStr(_tableName){

	var inputSliceName = "_info";

	var stringToReturn = "";
	var begin = "\n\n\t\tStrings.slice memory _info = _content.toSlice();\n\
	\tStrings.slice memory delim = \"|\".toSlice();";
	stringToReturn += begin +"\n\n";

	// ContractInfo memory cotrInfo;
	var newStructName = toFirsetLower(_tableName) +"Struct";
	stringToReturn += "\t\t" + _tableName + " memory " + newStructName +";";
	stringToReturn += "\n\n";

	// 分割代码
	 // cotrInfo.code = _info.split(delim).toString();
  //     cotrInfo.name = _info.split(delim).toString();
  	for (var i = 0; i < getFieldNamesFromTable(_tableName).length; i++) {

  		var ss1 = newStructName +"." + getFieldNamesFromTable(_tableName)[i] + " = " 
  		var ss2 = ss1 + inputSliceName + ".split(delim).toString();";
  		ss2 += "\n";

  		stringToReturn += "\t\t" + ss2;
  		if (i%3 == 2) stringToReturn += "\n";//每三个分一组
  	}
    stringToReturn += "\n\n";


	return {"newStructName" : newStructName,"result":stringToReturn};
}

      
      

   
//产生 add方法里 其他的 存储到block中 发射事件等的代码
function formLinesOfOtherInfoAndStoreInBlockFromAddMethod(_tableName, _newStructName){

		var stringToReturn = "";
		stringToReturn += "\t\t" + _newStructName + ".blockCreated = now;";
		stringToReturn += "\n";
		stringToReturn += "\t\t" + _newStructName + ".lastModifyTime = now;";
		stringToReturn += "\n";
		stringToReturn += "\t\t" + _newStructName + ".blockStatus = normal;";
		stringToReturn += "\n"; 
		// code2CotrInfo[cotrInfo.code] = cotrInfo;
		stringToReturn += "\t\tcode2" +_tableName + "[" + _newStructName + 
							"." + getFieldNamesFromTable(_tableName)[0] + "] = " + _newStructName +";";
		stringToReturn += "\n\n";

		   // code_ = cotrInfo.code;
     //  WriteSuccessEvent(code_);
     	stringToReturn += "\t\tcode_ = " + _newStructName + "." +getFieldNamesFromTable(_tableName)[0] + ";";
     	stringToReturn += "\n";
     	stringToReturn += "\t\tWriteSuccessEvent(code_);";
     	stringToReturn += "\n";
		return stringToReturn;
}



//产生其他的辅助函数和变量
function formImplNoTableFunctionsAndVars() {
	var stringToReturn = fs.readFileSync("./templateManageImpl.sol").toString();

	var begin = stringToReturn.indexOf(otherFunctionBegin);
	var end = stringToReturn.indexOf(otherFunctionEnd);
	//去除开头分隔符
	begin += otherFunctionBegin.length+1;

	stringToReturn = stringToReturn.substring(begin,end);
	stringToReturn += "\n\n";
	return stringToReturn;
}

//产生实现文件的 头
function formImplHeader() {
	var stringToReturn = fs.readFileSync("./templateManageImpl.sol").toString();
	var headerEnd = stringToReturn.indexOf(headerBegin);
	stringToReturn = stringToReturn.substring(0,headerEnd);

	//更改
	stringToReturn = stringToReturn.replace(/AuthManageInterface/g,fileNames[2]);
	stringToReturn = stringToReturn.replace(/AuthManageStorage/g,fileNames[3]);
	stringToReturn = stringToReturn.replace(/AuthManageImpl/g,fileNames[1]);

	return stringToReturn;
}
// ///初始化函数存储空间
// //模板
// addTemplate1 = "sizes[bytes4(sha3(\"ADD_FUNCTION(string)\"))]  = 32;";//bool string 
// addTemplate2 = "sizes[bytes4(sha3(\"QUERY_FUNCTION(string)\"))]  = uint32(SizeType.ST_STRING_3200);";//json string
// addTemplate3 = "sizes[bytes4(sha3(\"DEL_FUNCTION(string)\"))]  = uint32(SizeType.ST_NONE);";
// addTemplate4 = "";

function formImplInitia(_tableName) {

	var stringToReturn = "";

	stringToReturn += fromImplInitialFunctionSignatureFromTable(_tableName);
	stringToReturn += "\n\n";


	
	return stringToReturn;
}


//产生一个对应表的 所有方法的signature
function fromImplInitialFunctionSignatureFromTable(_tableName){

	var stringToReturn = "";

	stringToReturn += "\t\t" +addTemplate1.replace(/ADD_FUNCTION/, formFunctionName(_tableName)[0]);
	stringToReturn += "\n";
	stringToReturn +=  "\t\t" +addTemplate1.replace(/ADD_FUNCTION/, formFunctionName(_tableName)[1]);
	stringToReturn += "\n";
	stringToReturn +=  "\t\t" +addTemplate2.replace(/QUERY_FUNCTION/, formFunctionName(_tableName)[2]);
	stringToReturn += "\n";
	stringToReturn +=  "\t\t" +addTemplate3.replace(/DEL_FUNCTION/, formFunctionName(_tableName)[3]);
	stringToReturn += "\n";

	return stringToReturn;
}

//产生一个表的结构体每行的字段 和对应的mapping
function formStructFiledLine(_tableName){

	if (getFieldNamesFromTable(_tableName).length != getFieldCommentNamesFromTable(_tableName).length){
		mLog("字段注释和字段数量不一样啊 检查一个这个表 " + _tableName);
		return 2;
	}

	var stringToReturn = "";
	for (var i = 0; i < getFieldNamesFromTable(_tableName).length; i++) {
		stringToReturn += "\t\tstring " + getFieldNamesFromTable(_tableName)[i] +";\/\/" + getFieldCommentNamesFromTable(_tableName)[i] +";\n";
	}
	stringToReturn += "		uint blockCreated;\/\/记录区块链时间now\n";
	stringToReturn += "		uint lastModifyTime;\/\/最后修改时间now\n";
	stringToReturn += "		string blockStatus;\/\/当前记录的状态，默认：normal，已删除为：cancel \n";
	return stringToReturn;
}

//产生一个表的各种接口line (方法prototype)
function geInterfaceForTable(_tableName) {
	var methodNames = formFunctionName(_tableName);
	var string_;

	string_ = "\t" +geAddInterface(methodNames[0]) +";\n\n";
	string_ += "\t" +geChangeInterface(methodNames[1]) +";\n\n";
	string_ += "\t" +geQueryInterface(methodNames[2]) +";\n\n";
	string_ += "\t" +geDelInterface(methodNames[3]) +";\n\n";
	return string_;
}

//产生一个表的四个方法名字
function formFunctionName(_tableName){
	var tempArray = new Array();
	tempArray.push("add" + toFirstUpper(_tableName) );
	tempArray.push("change" + toFirstUpper(_tableName) );
	tempArray.push("query" + toFirstUpper(_tableName) );
	tempArray.push("del" +toFirstUpper(_tableName) );
	return tempArray;
}

//分别产生四种的函数 接口名
//产生add
//function addContractInfo(string _content) returns(string code_)
function geAddInterface(_fName) {
	var string_ = "function " + _fName +"(string _content) returns(string code_)";
	return string_;
}

//function changeContractInfo(string _content) returns(string code_)
function geChangeInterface(_fName) {
	return geAddInterface(_fName);
}
// function queryContractInfo(string _code) returns(string json_)
function geQueryInterface(_fName){
	return "function " + _fName +"(string _code) returns(string json_)";
}

// 	function delContractInfo(string _code);
function geDelInterface(_fName){
	return "function " + _fName +"(string _code)";
}

//通过map取回结构体的那句话
// code2CotrInfo[cotrInfo.code];
function formRetrieveStuctOfMapFromNewStruct(_tableName, _newStructName){
	return "code2" + toFirstUpper(_tableName) +"[" + _newStructName + "." 
				   + getFieldNamesFromTable(_tableName)[0] +"]";
}

function formRetrieveStuctOfMapFromCode(_tableName){
	return "code2" + toFirstUpper(_tableName) +"[_code]";
}

//是否为空字符串
if ( isEmptyString(fileName) ) {
	mLog("定义的模板名字为空");
}


function mLog(_inString){
	console.log(_inString);
}

//第一个字母变大写
function toFirstUpper(_inString){
	var firstLetter = _inString.charAt(0);
	var firstLetterUpper = firstLetter.toUpperCase();
	return _inString.replace(firstLetter,firstLetterUpper);	
}

function toFirsetLower(_inString){
	var firstLetter = _inString.charAt(0);
	var firstLetterLower = firstLetter.toLowerCase();
	return _inString.replace(firstLetter,firstLetterLower);	
}


function isEmptyString(_inString) {
	
	return _inString.length == 0;
}