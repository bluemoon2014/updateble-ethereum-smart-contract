


contract MaterialManageInterface {


	function addMaterialInfo(string _content) returns(string code_);

	function changeMaterialInfo(string _content) returns(string code_);

	function queryMaterialInfo(string _code) returns(string json_);

	function delMaterialInfo(string _code);

//--------------------------MaterialInfo--------------------------

	function addMaterialApproval(string _content) returns(string code_);

	function changeMaterialApproval(string _content) returns(string code_);

	function queryMaterialApproval(string _code) returns(string json_);

	function delMaterialApproval(string _code);

//--------------------------MaterialApproval--------------------------

	function addMaterialChange(string _content) returns(string code_);

	function changeMaterialChange(string _content) returns(string code_);

	function queryMaterialChange(string _code) returns(string json_);

	function delMaterialChange(string _code);

//--------------------------MaterialChange--------------------------

	function addMaterialAmount(string _content) returns(string code_);

	function changeMaterialAmount(string _content) returns(string code_);

	function queryMaterialAmount(string _code) returns(string json_);

	function delMaterialAmount(string _code);

//--------------------------MaterialAmount--------------------------



    //-------定义事件---------------
	event WriteSuccessEvent(string desc);
	event WriteFailEvent(string desc);

}

