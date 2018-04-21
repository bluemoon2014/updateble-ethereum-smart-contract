


contract MaterialManageStorage {


	string cancel = "CANCEL";//无效状态
	string normal = "NORMAL";//有效状态

	struct MaterialInfo {
		string iamOnlyOne;//审批代码;
		string contractId;//合同;
		string approveDate;//批准日期;
		string approveStatus;//批准状态;
		string description;//描述;
		string created;//创建时间;
		string condParty;//乙方;
		string expectAmount;//暂估金额;
		string tempAmount;//暂定金额;
		string totalAmount;//总金额;
		uint blockCreated;//记录区块链时间now
		uint lastModifyTime;//最后修改时间now
		string blockStatus;//当前记录的状态，默认：normal，已删除为：cancel 
	}


	mapping (string => MaterialInfo) code2MaterialInfo;


	struct MaterialApproval {
		string iamOnlyTwo;//审批代码;
		string contractId;//合同;
		string approveDate;//批准日期;
		string approveStatus;//批准状态;
		string description;//描述;
		string created;//创建时间;
		string condParty;//乙方;
		string expectAmount;//暂估金额;
		string tempAmount;//暂定金额;
		string totalAmount;//总金额;
		uint blockCreated;//记录区块链时间now
		uint lastModifyTime;//最后修改时间now
		string blockStatus;//当前记录的状态，默认：normal，已删除为：cancel 
	}


	mapping (string => MaterialApproval) code2MaterialApproval;


	struct MaterialChange {
		string iamOnlyThree;//审批代码;
		string contractId;//合同;
		string approveDate;//批准日期;
		string approveStatus;//批准状态;
		string description;//描述;
		string created;//创建时间;
		string condParty;//乙方;
		string expectAmount;//暂估金额;
		string tempAmount;//暂定金额;
		string totalAmount;//总金额;
		uint blockCreated;//记录区块链时间now
		uint lastModifyTime;//最后修改时间now
		string blockStatus;//当前记录的状态，默认：normal，已删除为：cancel 
	}


	mapping (string => MaterialChange) code2MaterialChange;


	struct MaterialAmount {
		string iamOnlyFour;//审批代码;
		string contractId;//合同;
		string approveDate;//批准日期;
		string approveStatus;//批准状态;
		string description;//描述;
		string created;//创建时间;
		string condParty;//乙方;
		string expectAmount;//暂估金额;
		string tempAmount;//暂定金额;
		string totalAmount;//总金额;
		uint blockCreated;//记录区块链时间now
		uint lastModifyTime;//最后修改时间now
		string blockStatus;//当前记录的状态，默认：normal，已删除为：cancel 
	}


	mapping (string => MaterialAmount) code2MaterialAmount;




}

