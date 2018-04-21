import "./MaterialManageInterface.sol";
import "./Strings.sol";
import "./JsonObject.sol";
import "./UpgradeSupport.sol";
import "./MaterialManageStorage.sol";
import "./DateLib.sol";
import "./ContractAddressManage.sol";

/**
 * 提供基础数据同步
 */
contract MaterialManageImpl is UpgradeSupport,ContractAddressManage,MaterialManageStorage,MaterialManageInterface{
    using Strings for *;
    using StrMapping for *;
    using JsonObject for StrMapping.StrMap;
    using DateLib for DateLib.DateTime;

    ///初始化函数存储空间
	function initialize(){

		sizes[bytes4(sha3("addMaterialInfo(string)"))]  = 32;
		sizes[bytes4(sha3("changeMaterialInfo(string)"))]  = 32;
		sizes[bytes4(sha3("queryMaterialInfo(string)"))]  = uint32(SizeType.ST_STRING_3200);
		sizes[bytes4(sha3("delMaterialInfo(string)"))]  = uint32(SizeType.ST_NONE);


		sizes[bytes4(sha3("addMaterialApproval(string)"))]  = 32;
		sizes[bytes4(sha3("changeMaterialApproval(string)"))]  = 32;
		sizes[bytes4(sha3("queryMaterialApproval(string)"))]  = uint32(SizeType.ST_STRING_3200);
		sizes[bytes4(sha3("delMaterialApproval(string)"))]  = uint32(SizeType.ST_NONE);


		sizes[bytes4(sha3("addMaterialChange(string)"))]  = 32;
		sizes[bytes4(sha3("changeMaterialChange(string)"))]  = 32;
		sizes[bytes4(sha3("queryMaterialChange(string)"))]  = uint32(SizeType.ST_STRING_3200);
		sizes[bytes4(sha3("delMaterialChange(string)"))]  = uint32(SizeType.ST_NONE);


		sizes[bytes4(sha3("addMaterialAmount(string)"))]  = 32;
		sizes[bytes4(sha3("changeMaterialAmount(string)"))]  = 32;
		sizes[bytes4(sha3("queryMaterialAmount(string)"))]  = uint32(SizeType.ST_STRING_3200);
		sizes[bytes4(sha3("delMaterialAmount(string)"))]  = uint32(SizeType.ST_NONE);


	}


    address admin;//创建者
    StrMapping.StrMap pairs;
    DateLib.DateTime dt;


    //Constructor function
    function ContractStoreManageImpl(){
        admin = msg.sender;
    }
    //Only Admin could do something
    // modifier isAdmin(address add){
    //     if(msg.sender != admin) throw;
    // }

    //字符串是否为空 需要更改
    function needChange(string _target) internal returns(bool need_){

      need_ = !_target.toSlice().empty();
    }

    function isStringEqual(string _one, string _two) internal returns(bool is_){

      is_ = _one.toSlice().compare(_two.toSlice()) == 0;
    }
    

	function addMaterialInfo(string _content) returns(string code_){


		Strings.slice memory _info = _content.toSlice();
		Strings.slice memory delim = "|".toSlice();

		MaterialInfo memory materialInfoStruct;

		materialInfoStruct.iamOnlyOne = _info.split(delim).toString();
		materialInfoStruct.contractId = _info.split(delim).toString();
		materialInfoStruct.approveDate = _info.split(delim).toString();

		materialInfoStruct.approveStatus = _info.split(delim).toString();
		materialInfoStruct.description = _info.split(delim).toString();
		materialInfoStruct.created = _info.split(delim).toString();

		materialInfoStruct.condParty = _info.split(delim).toString();
		materialInfoStruct.expectAmount = _info.split(delim).toString();
		materialInfoStruct.tempAmount = _info.split(delim).toString();

		materialInfoStruct.totalAmount = _info.split(delim).toString();


		materialInfoStruct.blockCreated = now;
		materialInfoStruct.lastModifyTime = now;
		materialInfoStruct.blockStatus = normal;
		code2MaterialInfo[materialInfoStruct.iamOnlyOne] = materialInfoStruct;

		code_ = materialInfoStruct.iamOnlyOne;
		WriteSuccessEvent(code_);

	}


	function changeMaterialInfo(string _content) returns(string code_){



		Strings.slice memory _info = _content.toSlice();
		Strings.slice memory delim = "|".toSlice();

		MaterialInfo memory materialInfoStruct;

		materialInfoStruct.iamOnlyOne = _info.split(delim).toString();
		materialInfoStruct.contractId = _info.split(delim).toString();
		materialInfoStruct.approveDate = _info.split(delim).toString();

		materialInfoStruct.approveStatus = _info.split(delim).toString();
		materialInfoStruct.description = _info.split(delim).toString();
		materialInfoStruct.created = _info.split(delim).toString();

		materialInfoStruct.condParty = _info.split(delim).toString();
		materialInfoStruct.expectAmount = _info.split(delim).toString();
		materialInfoStruct.tempAmount = _info.split(delim).toString();

		materialInfoStruct.totalAmount = _info.split(delim).toString();




		MaterialInfo originMaterialInfoStruct = code2MaterialInfo[materialInfoStruct.iamOnlyOne];

		if (needChange(materialInfoStruct.contractId)){
			originMaterialInfoStruct.contractId = materialInfoStruct.contractId;
		}

		if (needChange(materialInfoStruct.approveDate)){
			originMaterialInfoStruct.approveDate = materialInfoStruct.approveDate;
		}

		if (needChange(materialInfoStruct.approveStatus)){
			originMaterialInfoStruct.approveStatus = materialInfoStruct.approveStatus;
		}

		if (needChange(materialInfoStruct.description)){
			originMaterialInfoStruct.description = materialInfoStruct.description;
		}

		if (needChange(materialInfoStruct.created)){
			originMaterialInfoStruct.created = materialInfoStruct.created;
		}

		if (needChange(materialInfoStruct.condParty)){
			originMaterialInfoStruct.condParty = materialInfoStruct.condParty;
		}

		if (needChange(materialInfoStruct.expectAmount)){
			originMaterialInfoStruct.expectAmount = materialInfoStruct.expectAmount;
		}

		if (needChange(materialInfoStruct.tempAmount)){
			originMaterialInfoStruct.tempAmount = materialInfoStruct.tempAmount;
		}

		if (needChange(materialInfoStruct.totalAmount)){
			originMaterialInfoStruct.totalAmount = materialInfoStruct.totalAmount;
		}



		originMaterialInfoStruct.lastModifyTime = now;
		code_ = materialInfoStruct.iamOnlyOne;
		WriteSuccessEvent(code_);


	}


	function queryMaterialInfo(string _code) returns(string json_){
		MaterialInfo originMaterialInfoStruct = code2MaterialInfo[_code];

		if( !isStringEqual(originMaterialInfoStruct.blockStatus, normal) )
		return "Already Deleted!";

		pairs.clear();
		pairs.insert("iamOnlyOne",originMaterialInfoStruct.iamOnlyOne);
		pairs.insert("contractId",originMaterialInfoStruct.contractId);
		pairs.insert("approveDate",originMaterialInfoStruct.approveDate);
		pairs.insert("approveStatus",originMaterialInfoStruct.approveStatus);
		pairs.insert("description",originMaterialInfoStruct.description);
		pairs.insert("created",originMaterialInfoStruct.created);
		pairs.insert("condParty",originMaterialInfoStruct.condParty);
		pairs.insert("expectAmount",originMaterialInfoStruct.expectAmount);
		pairs.insert("tempAmount",originMaterialInfoStruct.tempAmount);
		pairs.insert("totalAmount",originMaterialInfoStruct.totalAmount);

		json_ = pairs.stringTo(false);
	}


	function delMaterialInfo(string _code){

		MaterialInfo originMaterialInfoStruct = code2MaterialInfo[_code];
		originMaterialInfoStruct.blockStatus = cancel;
		originMaterialInfoStruct.lastModifyTime = now;
		WriteSuccessEvent("deleteSuccess");

	}


	function addMaterialApproval(string _content) returns(string code_){


		Strings.slice memory _info = _content.toSlice();
		Strings.slice memory delim = "|".toSlice();

		MaterialApproval memory materialApprovalStruct;

		materialApprovalStruct.iamOnlyTwo = _info.split(delim).toString();
		materialApprovalStruct.contractId = _info.split(delim).toString();
		materialApprovalStruct.approveDate = _info.split(delim).toString();

		materialApprovalStruct.approveStatus = _info.split(delim).toString();
		materialApprovalStruct.description = _info.split(delim).toString();
		materialApprovalStruct.created = _info.split(delim).toString();

		materialApprovalStruct.condParty = _info.split(delim).toString();
		materialApprovalStruct.expectAmount = _info.split(delim).toString();
		materialApprovalStruct.tempAmount = _info.split(delim).toString();

		materialApprovalStruct.totalAmount = _info.split(delim).toString();


		materialApprovalStruct.blockCreated = now;
		materialApprovalStruct.lastModifyTime = now;
		materialApprovalStruct.blockStatus = normal;
		code2MaterialApproval[materialApprovalStruct.iamOnlyTwo] = materialApprovalStruct;

		code_ = materialApprovalStruct.iamOnlyTwo;
		WriteSuccessEvent(code_);

	}


	function changeMaterialApproval(string _content) returns(string code_){



		Strings.slice memory _info = _content.toSlice();
		Strings.slice memory delim = "|".toSlice();

		MaterialApproval memory materialApprovalStruct;

		materialApprovalStruct.iamOnlyTwo = _info.split(delim).toString();
		materialApprovalStruct.contractId = _info.split(delim).toString();
		materialApprovalStruct.approveDate = _info.split(delim).toString();

		materialApprovalStruct.approveStatus = _info.split(delim).toString();
		materialApprovalStruct.description = _info.split(delim).toString();
		materialApprovalStruct.created = _info.split(delim).toString();

		materialApprovalStruct.condParty = _info.split(delim).toString();
		materialApprovalStruct.expectAmount = _info.split(delim).toString();
		materialApprovalStruct.tempAmount = _info.split(delim).toString();

		materialApprovalStruct.totalAmount = _info.split(delim).toString();




		MaterialApproval originMaterialApprovalStruct = code2MaterialApproval[materialApprovalStruct.iamOnlyTwo];

		if (needChange(materialApprovalStruct.contractId)){
			originMaterialApprovalStruct.contractId = materialApprovalStruct.contractId;
		}

		if (needChange(materialApprovalStruct.approveDate)){
			originMaterialApprovalStruct.approveDate = materialApprovalStruct.approveDate;
		}

		if (needChange(materialApprovalStruct.approveStatus)){
			originMaterialApprovalStruct.approveStatus = materialApprovalStruct.approveStatus;
		}

		if (needChange(materialApprovalStruct.description)){
			originMaterialApprovalStruct.description = materialApprovalStruct.description;
		}

		if (needChange(materialApprovalStruct.created)){
			originMaterialApprovalStruct.created = materialApprovalStruct.created;
		}

		if (needChange(materialApprovalStruct.condParty)){
			originMaterialApprovalStruct.condParty = materialApprovalStruct.condParty;
		}

		if (needChange(materialApprovalStruct.expectAmount)){
			originMaterialApprovalStruct.expectAmount = materialApprovalStruct.expectAmount;
		}

		if (needChange(materialApprovalStruct.tempAmount)){
			originMaterialApprovalStruct.tempAmount = materialApprovalStruct.tempAmount;
		}

		if (needChange(materialApprovalStruct.totalAmount)){
			originMaterialApprovalStruct.totalAmount = materialApprovalStruct.totalAmount;
		}



		originMaterialApprovalStruct.lastModifyTime = now;
		code_ = materialApprovalStruct.iamOnlyTwo;
		WriteSuccessEvent(code_);


	}


	function queryMaterialApproval(string _code) returns(string json_){
		MaterialApproval originMaterialApprovalStruct = code2MaterialApproval[_code];

		if( !isStringEqual(originMaterialApprovalStruct.blockStatus, normal) )
		return "Already Deleted!";

		pairs.clear();
		pairs.insert("iamOnlyTwo",originMaterialApprovalStruct.iamOnlyTwo);
		pairs.insert("contractId",originMaterialApprovalStruct.contractId);
		pairs.insert("approveDate",originMaterialApprovalStruct.approveDate);
		pairs.insert("approveStatus",originMaterialApprovalStruct.approveStatus);
		pairs.insert("description",originMaterialApprovalStruct.description);
		pairs.insert("created",originMaterialApprovalStruct.created);
		pairs.insert("condParty",originMaterialApprovalStruct.condParty);
		pairs.insert("expectAmount",originMaterialApprovalStruct.expectAmount);
		pairs.insert("tempAmount",originMaterialApprovalStruct.tempAmount);
		pairs.insert("totalAmount",originMaterialApprovalStruct.totalAmount);

		json_ = pairs.stringTo(false);
	}


	function delMaterialApproval(string _code){

		MaterialApproval originMaterialApprovalStruct = code2MaterialApproval[_code];
		originMaterialApprovalStruct.blockStatus = cancel;
		originMaterialApprovalStruct.lastModifyTime = now;
		WriteSuccessEvent("deleteSuccess");

	}


	function addMaterialChange(string _content) returns(string code_){


		Strings.slice memory _info = _content.toSlice();
		Strings.slice memory delim = "|".toSlice();

		MaterialChange memory materialChangeStruct;

		materialChangeStruct.iamOnlyThree = _info.split(delim).toString();
		materialChangeStruct.contractId = _info.split(delim).toString();
		materialChangeStruct.approveDate = _info.split(delim).toString();

		materialChangeStruct.approveStatus = _info.split(delim).toString();
		materialChangeStruct.description = _info.split(delim).toString();
		materialChangeStruct.created = _info.split(delim).toString();

		materialChangeStruct.condParty = _info.split(delim).toString();
		materialChangeStruct.expectAmount = _info.split(delim).toString();
		materialChangeStruct.tempAmount = _info.split(delim).toString();

		materialChangeStruct.totalAmount = _info.split(delim).toString();


		materialChangeStruct.blockCreated = now;
		materialChangeStruct.lastModifyTime = now;
		materialChangeStruct.blockStatus = normal;
		code2MaterialChange[materialChangeStruct.iamOnlyThree] = materialChangeStruct;

		code_ = materialChangeStruct.iamOnlyThree;
		WriteSuccessEvent(code_);

	}


	function changeMaterialChange(string _content) returns(string code_){



		Strings.slice memory _info = _content.toSlice();
		Strings.slice memory delim = "|".toSlice();

		MaterialChange memory materialChangeStruct;

		materialChangeStruct.iamOnlyThree = _info.split(delim).toString();
		materialChangeStruct.contractId = _info.split(delim).toString();
		materialChangeStruct.approveDate = _info.split(delim).toString();

		materialChangeStruct.approveStatus = _info.split(delim).toString();
		materialChangeStruct.description = _info.split(delim).toString();
		materialChangeStruct.created = _info.split(delim).toString();

		materialChangeStruct.condParty = _info.split(delim).toString();
		materialChangeStruct.expectAmount = _info.split(delim).toString();
		materialChangeStruct.tempAmount = _info.split(delim).toString();

		materialChangeStruct.totalAmount = _info.split(delim).toString();




		MaterialChange originMaterialChangeStruct = code2MaterialChange[materialChangeStruct.iamOnlyThree];

		if (needChange(materialChangeStruct.contractId)){
			originMaterialChangeStruct.contractId = materialChangeStruct.contractId;
		}

		if (needChange(materialChangeStruct.approveDate)){
			originMaterialChangeStruct.approveDate = materialChangeStruct.approveDate;
		}

		if (needChange(materialChangeStruct.approveStatus)){
			originMaterialChangeStruct.approveStatus = materialChangeStruct.approveStatus;
		}

		if (needChange(materialChangeStruct.description)){
			originMaterialChangeStruct.description = materialChangeStruct.description;
		}

		if (needChange(materialChangeStruct.created)){
			originMaterialChangeStruct.created = materialChangeStruct.created;
		}

		if (needChange(materialChangeStruct.condParty)){
			originMaterialChangeStruct.condParty = materialChangeStruct.condParty;
		}

		if (needChange(materialChangeStruct.expectAmount)){
			originMaterialChangeStruct.expectAmount = materialChangeStruct.expectAmount;
		}

		if (needChange(materialChangeStruct.tempAmount)){
			originMaterialChangeStruct.tempAmount = materialChangeStruct.tempAmount;
		}

		if (needChange(materialChangeStruct.totalAmount)){
			originMaterialChangeStruct.totalAmount = materialChangeStruct.totalAmount;
		}



		originMaterialChangeStruct.lastModifyTime = now;
		code_ = materialChangeStruct.iamOnlyThree;
		WriteSuccessEvent(code_);


	}


	function queryMaterialChange(string _code) returns(string json_){
		MaterialChange originMaterialChangeStruct = code2MaterialChange[_code];

		if( !isStringEqual(originMaterialChangeStruct.blockStatus, normal) )
		return "Already Deleted!";

		pairs.clear();
		pairs.insert("iamOnlyThree",originMaterialChangeStruct.iamOnlyThree);
		pairs.insert("contractId",originMaterialChangeStruct.contractId);
		pairs.insert("approveDate",originMaterialChangeStruct.approveDate);
		pairs.insert("approveStatus",originMaterialChangeStruct.approveStatus);
		pairs.insert("description",originMaterialChangeStruct.description);
		pairs.insert("created",originMaterialChangeStruct.created);
		pairs.insert("condParty",originMaterialChangeStruct.condParty);
		pairs.insert("expectAmount",originMaterialChangeStruct.expectAmount);
		pairs.insert("tempAmount",originMaterialChangeStruct.tempAmount);
		pairs.insert("totalAmount",originMaterialChangeStruct.totalAmount);

		json_ = pairs.stringTo(false);
	}


	function delMaterialChange(string _code){

		MaterialChange originMaterialChangeStruct = code2MaterialChange[_code];
		originMaterialChangeStruct.blockStatus = cancel;
		originMaterialChangeStruct.lastModifyTime = now;
		WriteSuccessEvent("deleteSuccess");

	}


	function addMaterialAmount(string _content) returns(string code_){


		Strings.slice memory _info = _content.toSlice();
		Strings.slice memory delim = "|".toSlice();

		MaterialAmount memory materialAmountStruct;

		materialAmountStruct.iamOnlyFour = _info.split(delim).toString();
		materialAmountStruct.contractId = _info.split(delim).toString();
		materialAmountStruct.approveDate = _info.split(delim).toString();

		materialAmountStruct.approveStatus = _info.split(delim).toString();
		materialAmountStruct.description = _info.split(delim).toString();
		materialAmountStruct.created = _info.split(delim).toString();

		materialAmountStruct.condParty = _info.split(delim).toString();
		materialAmountStruct.expectAmount = _info.split(delim).toString();
		materialAmountStruct.tempAmount = _info.split(delim).toString();

		materialAmountStruct.totalAmount = _info.split(delim).toString();


		materialAmountStruct.blockCreated = now;
		materialAmountStruct.lastModifyTime = now;
		materialAmountStruct.blockStatus = normal;
		code2MaterialAmount[materialAmountStruct.iamOnlyFour] = materialAmountStruct;

		code_ = materialAmountStruct.iamOnlyFour;
		WriteSuccessEvent(code_);

	}


	function changeMaterialAmount(string _content) returns(string code_){



		Strings.slice memory _info = _content.toSlice();
		Strings.slice memory delim = "|".toSlice();

		MaterialAmount memory materialAmountStruct;

		materialAmountStruct.iamOnlyFour = _info.split(delim).toString();
		materialAmountStruct.contractId = _info.split(delim).toString();
		materialAmountStruct.approveDate = _info.split(delim).toString();

		materialAmountStruct.approveStatus = _info.split(delim).toString();
		materialAmountStruct.description = _info.split(delim).toString();
		materialAmountStruct.created = _info.split(delim).toString();

		materialAmountStruct.condParty = _info.split(delim).toString();
		materialAmountStruct.expectAmount = _info.split(delim).toString();
		materialAmountStruct.tempAmount = _info.split(delim).toString();

		materialAmountStruct.totalAmount = _info.split(delim).toString();




		MaterialAmount originMaterialAmountStruct = code2MaterialAmount[materialAmountStruct.iamOnlyFour];

		if (needChange(materialAmountStruct.contractId)){
			originMaterialAmountStruct.contractId = materialAmountStruct.contractId;
		}

		if (needChange(materialAmountStruct.approveDate)){
			originMaterialAmountStruct.approveDate = materialAmountStruct.approveDate;
		}

		if (needChange(materialAmountStruct.approveStatus)){
			originMaterialAmountStruct.approveStatus = materialAmountStruct.approveStatus;
		}

		if (needChange(materialAmountStruct.description)){
			originMaterialAmountStruct.description = materialAmountStruct.description;
		}

		if (needChange(materialAmountStruct.created)){
			originMaterialAmountStruct.created = materialAmountStruct.created;
		}

		if (needChange(materialAmountStruct.condParty)){
			originMaterialAmountStruct.condParty = materialAmountStruct.condParty;
		}

		if (needChange(materialAmountStruct.expectAmount)){
			originMaterialAmountStruct.expectAmount = materialAmountStruct.expectAmount;
		}

		if (needChange(materialAmountStruct.tempAmount)){
			originMaterialAmountStruct.tempAmount = materialAmountStruct.tempAmount;
		}

		if (needChange(materialAmountStruct.totalAmount)){
			originMaterialAmountStruct.totalAmount = materialAmountStruct.totalAmount;
		}



		originMaterialAmountStruct.lastModifyTime = now;
		code_ = materialAmountStruct.iamOnlyFour;
		WriteSuccessEvent(code_);


	}


	function queryMaterialAmount(string _code) returns(string json_){
		MaterialAmount originMaterialAmountStruct = code2MaterialAmount[_code];

		if( !isStringEqual(originMaterialAmountStruct.blockStatus, normal) )
		return "Already Deleted!";

		pairs.clear();
		pairs.insert("iamOnlyFour",originMaterialAmountStruct.iamOnlyFour);
		pairs.insert("contractId",originMaterialAmountStruct.contractId);
		pairs.insert("approveDate",originMaterialAmountStruct.approveDate);
		pairs.insert("approveStatus",originMaterialAmountStruct.approveStatus);
		pairs.insert("description",originMaterialAmountStruct.description);
		pairs.insert("created",originMaterialAmountStruct.created);
		pairs.insert("condParty",originMaterialAmountStruct.condParty);
		pairs.insert("expectAmount",originMaterialAmountStruct.expectAmount);
		pairs.insert("tempAmount",originMaterialAmountStruct.tempAmount);
		pairs.insert("totalAmount",originMaterialAmountStruct.totalAmount);

		json_ = pairs.stringTo(false);
	}


	function delMaterialAmount(string _code){

		MaterialAmount originMaterialAmountStruct = code2MaterialAmount[_code];
		originMaterialAmountStruct.blockStatus = cancel;
		originMaterialAmountStruct.lastModifyTime = now;
		WriteSuccessEvent("deleteSuccess");

	}




}



