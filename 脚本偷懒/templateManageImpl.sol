import "./AuthManageInterface.sol";
import "./Strings.sol";
import "./JsonObject.sol";
import "./UpgradeSupport.sol";
import "./AuthManageStorage.sol";
import "./DateLib.sol";
import "./ContractAddressManage.sol";

/**
 * 提供基础数据同步
 */
contract AuthManageImpl is UpgradeSupport,ContractAddressManage,AuthManageStorage,AuthManageInterface{
    using Strings for *;
    using StrMapping for *;
    using JsonObject for StrMapping.StrMap;
    using DateLib for DateLib.DateTime;

    //TEMPLATE_HEADER
    ///初始化函数存储空间
    function initialize(){
      sizes[bytes4(sha3("addAccInfo(string)"))]  = 32;
      sizes[bytes4(sha3("queryAccList(uint256,uint256)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("queryAccInfo(string,string)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("delAccInfo(string)"))]  = 32;
      sizes[bytes4(sha3("modAccInfo(string,string)"))]  = 32;
      sizes[bytes4(sha3("batchAccInfo(string,string,string,string)"))]  = 32;
      sizes[bytes4(sha3("addUrlInfo(string,string,string,string,string,string,string,string)"))]  = 32;
      sizes[bytes4(sha3("queryUrlInfoList(uint256,uint256)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("queryUrlInfo(string)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("delUrlInfo(string)"))]  = 32;
      sizes[bytes4(sha3("modUrlInfo(string,string,string,string)"))]  = 32;
      sizes[bytes4(sha3("addRoleInfo(string,string,string,string,string,string,string,string,string)"))]  = 32;
      sizes[bytes4(sha3("queryRoleInfoList(uint256,uint256)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("queryRoleInfo(string)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("delRoleInfo(string)"))]  = 32;
      sizes[bytes4(sha3("modRoleInfo(string,string,string,string)"))]  = 32;
      sizes[bytes4(sha3("batchUrlToRole(string,string)"))]  = 32;
      sizes[bytes4(sha3("batchAccToRole(string,string)"))]  = 32;
      sizes[bytes4(sha3("addPositionInfo(string,string,string,string,string,string)"))]  = 32;
      sizes[bytes4(sha3("queryPositionList(uint256,uint256)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("queryPositionInfo(string)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("delPositionInfo(string)"))]  = 32;
      sizes[bytes4(sha3("modPositionInfo(string,string,string)"))]  = 32;
      sizes[bytes4(sha3("addDeptInfo(string)"))]  = 32;
      sizes[bytes4(sha3("queryDeptInfoList(uint256,uint256)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("queryDeptInfo(string)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("modDeptInfo(string)"))]  = 32;
      sizes[bytes4(sha3("delDeptInfo(string)"))]  = 32;
      sizes[bytes4(sha3("queryDeptToPositionList(string,uint256,uint256)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("queryDeptToAccList(string,uint256,uint256)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("queryPositionToAccList(string,uint256,uint256)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("querRoleToAccList(string,uint256,uint256)"))]  = uint32(SizeType.ST_STRING_3200);
      sizes[bytes4(sha3("bindUrl(string,string,string)"))]  = 32;
    }
    //TEMPLATE_OTHER_FUNCTION_BEGIN
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
    //TEMPLATE_OTHER_FUNCTION_END

    //Only Admin could do something
    // modifier isAdmin(address add){
    //     if(msg.sender != admin) throw;
    // }
   function set(uint _in, string vv) {
        lolo[_in] = vv;
    }
    
    function get(uint _in) view returns(string){
        return lolo[_in];
    }


//=========================用户信息======begin==================================
    uint accId = 0;//递增生成,用户记录在区块链里的唯一标示号(用户信息)
    /*
     * @dev 判断是否_userName已经存在被占用
     * @param   string _userName   用户名
     * @return  bool _isExist   返回是否存在
     */
    function isExistUsername(string _userName) returns(bool){
        string accCode = accUserNames[_userName];
        if (accCode.toSlice().empty()) {
          return true;
        }else{
          WriteFailEvent("用户名已存在");
          return false;//返回 不存在
        }

    }

    /*
      * 添加一条信息
      * @param
      * @参数顺序：user_name|password|trade_no|metadata|hdAddress|privateKey，即用户名|密码|业务流水单号|备注信息|公钥|私钥
      * @returns(uint)//生成的ID
    */
    function addAccInfo(string _txContent) returns(uint){

          accId = accId + 1;//递增加1
          /*提供用户信息的数据存储接口*/
          AccInfo memory info;
          var infoSlice = _txContent.toSlice();
          /*定义切片变量*/
          var delim = "|".toSlice();
          //区块链用户信息自动生成
          info.accId = accId;
          info.accCode = infoSlice.split(delim).toString(); //用户CODE
          info.account = infoSlice.split(delim).toString(); //账号
          info.userName = infoSlice.split(delim).toString(); //账户名
          if (!isExistUsername(info.userName)) {
            return 0;
          }
          info.password = infoSlice.split(delim).toString(); //账户密码
          info.accNo = infoSlice.split(delim).toString();//工号
          info.companyCode = infoSlice.split(delim).toString(); //公司CODE
          info.deptCode = infoSlice.split(delim).toString(); //部门CODE
          info.positionCode = infoSlice.split(delim).toString(); //岗位CODE
          info.roleCode = infoSlice.split(delim).toString();//角色COde
          info.email = infoSlice.split(delim).toString(); //邮箱
          info.mobile = infoSlice.split(delim).toString(); //联系方式
          info.enabled = infoSlice.split(delim).toString(); //是否禁用
          info.tradeNo = infoSlice.split(delim).toString(); //凭据号,开发者需要保证其唯一，与业务系统关联
          info.metadata = infoSlice.split(delim).toString(); //自定义字段
          info.hdAddress = infoSlice.split(delim).toString(); //公钥
          info.privateKey = infoSlice.split(delim).toString(); //私钥

          info.status = normal; //有效状态
          info.created = now; //创建用户信息 记录区块链时间now
          info.lastModifyTime = now; //最后修改时间

          accs[info.accCode] = info;
          accUserNames[info.userName] = info.accCode;
          accNos[info.accNo] = info.accCode;
          accAdds[info.hdAddress] = info.accCode;
          accCodes.push(info.accCode);
          //产生成功事件
          WriteSuccessEvent(accId.uintToBytes().bytes32ToString());
          return accId;//返回区块链分配的ID
        }

        /*
      * 查找列表
      * @pageNo 开始查询的索引号，即用户accId
      * @pageSize 分页Size  如 accId=5,pageSize=10，那么返回accId在5-14范围的所有用户信息
      * @returns string json//返回所有用户列表的json字符串，管理员使用。
    */
    function queryAccList(uint pageNo,uint pageSize) returns(string _json){
      uint len = accCodes.length;
      _json = "{\"total\":\"";
      string memory list = "";
      uint ignoreRecords = (pageNo-1)*pageSize;  //需要忽略的记录数
      uint totalRecords = 0; //总记录数
      bool inited = false;
      if(len > 0){
        for(uint i=0; i<len; ++i) {
          AccInfo acc = accs[accCodes[i]];
            if (Strings.equals(normal.toSlice(), acc.status.toSlice())) {
              totalRecords++;
              if((totalRecords > ignoreRecords) && (totalRecords < (ignoreRecords+pageSize+1))) {
                pairs.clear();
                pairs.insert("accId",acc.accId.uintToBytes().bytes32ToString());
                pairs.insert("accCode",acc.accCode);//用户CODE
                pairs.insert("account",acc.account);//账户
                pairs.insert("userName",acc.userName);//账户名
                pairs.insert("password",acc.password);//账户密码
                pairs.insert("accNo",acc.accNo);//工号
                pairs.insert("companyCode",acc.companyCode);//公司CODE
                pairs.insert("depName", deptInfos[acc.deptCode].depName);//部门名称
                pairs.insert("deptCode",acc.deptCode);//部门CODE
                pairs.insert("positionCode",acc.positionCode);//岗位CODE
                pairs.insert("positionName", positions[acc.positionCode].positionName);//部门名称
                pairs.insert("roleCode", acc.roleCode);//角色Code
                pairs.insert("roleName", roles[acc.roleCode].roleName);//角色名称
                pairs.insert("urlCode", acc.urlCode);//绑定菜单code
                pairs.insert("unBindUrlCode", acc.unBindUrlCode);//解绑的菜单code
                pairs.insert("email",acc.email);//邮箱
                pairs.insert("mobile",acc.mobile);//联系方式
                pairs.insert("enabled",acc.enabled);//是否禁用

                pairs.insert("tradeNo",acc.tradeNo);//凭据号,开发者需要保证其唯一，与业务系统关联
                pairs.insert("metadata",acc.metadata);//自定义字段
                pairs.insert("hdAddress",acc.hdAddress);//区块链账户公钥地址
                pairs.insert("status",acc.status);//用户状态
                pairs.insert("created",acc.created.uintToBytes().bytes32ToString());
                pairs.insert("lastModifyTime",acc.lastModifyTime.uintToBytes().bytes32ToString());
                string memory accJson = pairs.stringTo(false);
                if(inited) {
                  list = list.toSlice().concat(",".toSlice());
                }
                list = list.toSlice().concat(accJson.toSlice());
                inited = true;
              }
            }

        }
      }
      _json = _json.toSlice().concat(totalRecords.uintToBytes().bytes32ToString().toSlice());
      _json = _json.toSlice().concat("\",\"list\":[".toSlice());
      _json = _json.toSlice().concat(list.toSlice());
      _json = _json.toSlice().concat("]}".toSlice());
      return _json;
    }

    /*
      *查找单个详情
      *@param uint _accCode,//用户CODE
      *@param string _hdAddress,//区块链账户地址 （accId不为空则以accId查询，否则用hdAddress查询）
      *@returns string
    */
    function queryAccInfo(string _accCode, string _hdAddress) returns(string _json){
      string memory object = "";
      if(_accCode.toSlice().empty()){//判断条件是否又输入id
        _accCode = accAdds[_hdAddress];//通过地址找到accId
      }
      //先用accId查询，
        AccInfo acc = accs[_accCode];
        if(Strings.compare(normal.toSlice(),acc.status.toSlice()) == 0){
          pairs.clear();
          pairs.insert("accId",acc.accId.uintToBytes().bytes32ToString());
          pairs.insert("accCode",acc.accCode);//用户CODE
          pairs.insert("account",acc.account);//账户
          pairs.insert("userName",acc.userName);//账户名
          pairs.insert("password",acc.password);//账户密码
          pairs.insert("accNo",acc.accNo);//工号
          pairs.insert("companyCode",acc.companyCode);//公司CODE
          pairs.insert("deptCode",acc.deptCode);//部门CODE
          pairs.insert("positionCode",acc.positionCode);//岗位CODE
          pairs.insert("urlCode", acc.urlCode);//绑定菜单code
          pairs.insert("unBindUrlCode", acc.unBindUrlCode);//解绑的菜单code
          pairs.insert("email",acc.email);//邮箱
          pairs.insert("mobile",acc.mobile);//联系方式
          pairs.insert("enabled",acc.enabled);//是否禁用

          pairs.insert("tradeNo",acc.tradeNo);//凭据号,开发者需要保证其唯一，与业务系统关联
          pairs.insert("metadata",acc.metadata);//自定义字段
          pairs.insert("metadata",acc.hdAddress);//区块链账户公钥地址
          pairs.insert("status",acc.status);//用户状态
          pairs.insert("created",acc.created.uintToBytes().bytes32ToString());
          pairs.insert("lastModifyTime",acc.lastModifyTime.uintToBytes().bytes32ToString());
          string memory accJson = pairs.stringTo(false);
          object = object.toSlice().concat(accJson.toSlice());
        }else {
            WriteFailEvent("该条信息已被删除");
            _json = "";
        }
      _json = _json.toSlice().concat(object.toSlice());
      return _json;
    }

    /*
      * 删除一条信息
      * @param  string _accCode,//用户CODE
      * @returns(bool)//是否成功
    */
    function delAccInfo(string _accCode) returns(bool _success){
      _success = false;
      if(!(_accCode.toSlice().empty())){
          accs[_accCode].status = cancel; //无效状态
          accs[_accCode].lastModifyTime = now; //当前记录修改时间
          _success = true;
      }
      //产生成功事件
      WriteSuccessEvent("WriteSuccess");
      return _success;
    }

    /*
     * 修改一条信息
     * @param  string _accCode,//用户CODE
     * @param  string _content,//用户信息内容,多个参数按顺序以"|"相隔离。判断每一个参数值是否为空，为空则不修改
     * @returns(bool)
   */
   function modAccInfo(string _accCode, string _content) returns(bool){
     if(_accCode.toSlice().empty()){
       return false;
     }

     var infoSlice = _content.toSlice();
     /*定义切片变量*/
     var delim = "|".toSlice();
     /*提供用户信息的数据存储接口*/
     AccInfo memory accInfo;
     accInfo.password = infoSlice.split(delim).toString(); //账户密码
     accInfo.companyCode = infoSlice.split(delim).toString(); //公司CODE
     accInfo.deptCode = infoSlice.split(delim).toString(); //部门CODE
     accInfo.positionCode = infoSlice.split(delim).toString(); //岗位CODE
     accInfo.roleCode = infoSlice.split(delim).toString(); //角色CODE
     accInfo.email = infoSlice.split(delim).toString(); //邮箱
     accInfo.mobile = infoSlice.split(delim).toString(); //联系方式
     accInfo.enabled = infoSlice.split(delim).toString(); //是否禁用
     accInfo.metadata = infoSlice.split(delim).toString(); //自定义字段

     if(!(accInfo.password.toSlice().empty())){//传进来的参数不是空才修改
       accs[_accCode].password = accInfo.password;//账户名
     }
     if(!Strings.equals(accInfo.companyCode.toSlice(), "0".toSlice())){//传进来的参数不是空才修改
       accs[_accCode].companyCode = accInfo.companyCode;//账户密码
     }
     if(!Strings.equals(accInfo.deptCode.toSlice(), "0".toSlice())){//传进来的参数不是空才修改
       accs[_accCode].deptCode = accInfo.deptCode;//凭据号,开发者需要保证其唯一，与业务系统关联
     }
     if(!Strings.equals(accInfo.positionCode.toSlice(), "0".toSlice())){//传进来的参数不是空才修改
       accs[_accCode].positionCode = accInfo.positionCode;//凭据号,开发者需要保证其唯一，与业务系统关联
     }
     if(!Strings.equals(accInfo.roleCode.toSlice(), "0".toSlice())){//传进来的参数不是空才修改
       accs[_accCode].roleCode = accInfo.roleCode;//凭据号,开发者需要保证其唯一，与业务系统关联
     }
     if(!(accInfo.email.toSlice().empty())){//传进来的参数不是空才修改
       accs[_accCode].email = accInfo.email;//自定义字段
     }
     if(!(accInfo.mobile.toSlice().empty())){//传进来的参数不是空才修改
       accs[_accCode].mobile = accInfo.mobile;//自定义字段
     }
     if(!(accInfo.enabled.toSlice().empty())){//传进来的参数不是空才修改
       accs[_accCode].enabled = accInfo.enabled;//自定义字段
     }
     if(!(accInfo.metadata.toSlice().empty())){//传进来的参数不是空才修改
       accs[_accCode].metadata = accInfo.metadata;//自定义字段
     }
     //最后修改时间
     accs[_accCode].lastModifyTime = now;
     //产生成功事件
     WriteSuccessEvent("WriteSuccess");
     return true;//返回修改成功
   }

   /*
    * 批量分配用户的部门岗位或者角色
    * @param  string _deptCode,//部门CODE
    * @param  string _positionCode,//岗位CODE
    * @param  string _accCode,//用户Code，用|分割
    * @returns(bool)
  */
  function batchAccInfo(string _deptCode, string _positionCode, string _accCode, string _roleCode) returns(bool){
    if(_accCode.toSlice().empty()){
      return false;
    }

    var infoSlice = _accCode.toSlice();
    var infoSlice1 = _accCode.toSlice();
    string memory parts;
    /*定义切片变量*/
    var delim = "|".toSlice();
    for(uint i = 0; i < infoSlice1.count(delim)+1; i++) {
        if(infoSlice.contains(delim)){
            parts = infoSlice.split(delim).toString();
        }else{
            parts = infoSlice.toString();
        }
        if(!_deptCode.toSlice().empty()){
          accs[parts].deptCode = _deptCode;
        }
        if(!_deptCode.toSlice().empty()){
          accs[parts].positionCode = _positionCode;
        }
        if(!_roleCode.toSlice().empty()){
          accs[parts].roleCode = _roleCode;
        }
        //最后修改时间
        accs[parts].lastModifyTime = now;
    }
    //产生成功事件
    WriteSuccessEvent("WriteSuccess");
    return true;//返回修改成功
  }

   //=========================用户信息======end==================================

  //=========================菜单URL信息======begin==================================
        uint urlId = 0;//递增生成,用户记录在区块链里的唯一标示号(维护的URL信息)
        /*
          * 添加一条信息
          * @param  string _content,//信息内容，交易参数以"|"分割
          * @参数顺序:_urlCode|_parentId|_systemId|_companyCode|_name|_url|_icon|_createUser|_metadata
          * @returns(uint)//生成的ID
        */
        function addUrlInfo(string _urlCode,string _parentCode,string _systemCode,string _companyCode,
          string _name,string _url,string _createUser,string _metadata) returns(string){
            urlId = urlId + 1;  //递增加1
            /*提供信息的数据存储接口*/
            UrlInfo memory info;
            info.urlId = urlId;               //区块链信息自动生成
            info.urlCode = _urlCode;          //URLCODE
            info.parentCode = _parentCode;        //公司Code
            info.systemCode = _systemCode;        //系统Code
            info.companyCode = _companyCode;  //岗位名称
            info.name = _name;                //URL名称
            info.url = _url;                  //路径URL
            info.createUser = _createUser;    //角色类型

            info.metadata = _metadata;        //备用
            info.status = normal;             //有效状态
            info.created = now;               //记录区块链时间now
            info.lastModifyTime = now;        //最后修改时间
            /* mapping(string=>UrlInfo) urls;  //urlCode=>UrlInfo()*/
            urls[_urlCode] = info;
            //mapping(uint=>string) urlCodes;//urlId=>urlCodes
            urlCodes[urlId] = _urlCode;
            //urlCodesIds push code
            urlCodesIds.push(_urlCode);
            //产生成功事件
            WriteSuccessEvent(urlId.uintToBytes().bytes32ToString());
            return _urlCode;
          }

        /*
          * 查找列表
          * @pageNo 开始查询的索引号，即_roleCode
          * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回urlCode在5-10范围的所有用户信息
          * @returns string json//返回所有用户列表的json字符串，管理员使用。
        */
        function queryUrlInfoList(uint pageNo,uint pageSize) returns(string _json){
          uint len = urlCodesIds.length;
          _json = "{\"total\":\"";
          string memory list = "";
          uint ignoreRecords = (pageNo-1)*pageSize;  //需要忽略的记录数
          uint totalRecords = 0; //总记录数
          bool inited = false;
          if(len > 0){
            for(uint i=0; i<len; ++i) {
                UrlInfo info = urls[urlCodesIds[i]];
                totalRecords++;
                if((totalRecords > ignoreRecords) && (totalRecords < (ignoreRecords+pageSize+1))) {
                  pairs.clear();
                  pairs.insert("urlId",info.urlId.uintToBytes().bytes32ToString());
                  pairs.insert("urlCode",info.urlCode);//URLCODE
                  pairs.insert("parentCode",info.parentCode);//父CODE
                  pairs.insert("systemCode",info.systemCode);//系统Code
                  pairs.insert("companyCode",info.companyCode);//公司CODE
                  pairs.insert("name",info.name);//名称
                  pairs.insert("url",info.url);//URL
                  pairs.insert("createUser",info.createUser);//创建人
                  pairs.insert("metadata",info.metadata);//备用
                  pairs.insert("status",info.status);//状态
                  pairs.insert("created",info.created.uintToBytes().bytes32ToString());
                  pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());
                  string memory pairsJson = pairs.stringTo(false);
                  if(inited) {
                      list = list.toSlice().concat(",".toSlice());
                  }
                  list = list.toSlice().concat(pairsJson.toSlice());
                  inited = true;
                }
            }
          }
          _json = _json.toSlice().concat(totalRecords.uintToBytes().bytes32ToString().toSlice());
          _json = _json.toSlice().concat("\",\"list\":[".toSlice());
          _json = _json.toSlice().concat(list.toSlice());
          _json = _json.toSlice().concat("]}".toSlice());
          return _json;
        }

        /*
          *查找单个详情
          *@param string _roleCode,//查询的条件
          *@returns string
        */
        function queryUrlInfo(string _urlCode) returns(string _json){
          string memory object = "";
          string memory pairsJson = "";
          UrlInfo info = urls[_urlCode];
          if(!(info.urlCode.toSlice().empty())){
            pairs.clear();
            pairs.insert("urlId",info.urlId.uintToBytes().bytes32ToString());
            pairs.insert("urlCode",info.urlCode);//URLCODE
            pairs.insert("parentCode",info.parentCode);//父CODE
            pairs.insert("systemCode",info.systemCode);//系统Code
            pairs.insert("companyCode",info.companyCode);//公司CODE
            pairs.insert("name",info.name);//名称
            pairs.insert("url",info.url);//URL
            pairs.insert("createUser",info.createUser);//创建人
            pairs.insert("metadata",info.metadata);//备用
            pairs.insert("status",info.status);//状态
            pairs.insert("created",info.created.uintToBytes().bytes32ToString());
            pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());
            pairsJson = pairs.stringTo(false);
          }
          object = object.toSlice().concat(pairsJson.toSlice());
          _json = _json.toSlice().concat(object.toSlice());
          return _json;
        }

        /*
          * 删除一条信息
          * @param  uint _urlCode,//CODE
          * @returns(bool)//是否成功
        */
        function delUrlInfo(string _urlCode) returns(bool _success){
          _success = false;
          if(!(_urlCode.toSlice().empty())){//传进来的参数不是空才修改
              urls[_urlCode].status = cancel; //无效状态
              urls[_urlCode].lastModifyTime = now; //当前记录修改时间
              _success = true;
          }
          //产生成功事件
          WriteSuccessEvent("WriteSuccess");
          return _success;
        }

        /*
         * 修改一条信息
         * @param  uint _urlCode,//编号
         * @returns(bool)
       */
       function modUrlInfo(string _urlCode, string _name,string _url,string _metadata) returns(bool){
         if(_urlCode.toSlice().empty()){//传进来的参数为空就表示当前数据不能修改
           return false;
         }
         if(!(_name.toSlice().empty())){//传进来的参数不是空才修改
           urls[_urlCode].name = _name;//名称
         }
         if(!(_url.toSlice().empty())){//传进来的参数不是空才修改
           urls[_urlCode].url = _url;//URL路径
         }
         if(!(_metadata.toSlice().empty())){//传进来的参数不是空才修改
           urls[_urlCode].metadata = _metadata;//自定义字段
         }
         //最后修改时间
         urls[_urlCode].lastModifyTime = now;
         //产生成功事件
         WriteSuccessEvent("WriteSuccess");
         return true;//返回修改成功
       }

    //=========================菜单URL信息======end==================================

    //=========================角色信息======begin==================================
	   uint roleId = 0;//递增生成,用户记录在区块链里的唯一标示号(维护的角色信息)
        /*
          * 添加一条角色信息
          * @param  string _content,//信息内容，交易参数以"|"分割
          * @参数顺序：_roleCode|_companyCode|_parentId|_urlCode|_roleName|_roleType|_enabled|_metadata
          * @returns(uint)//生成的ID
        */
        function addRoleInfo(string _roleCode,string _companyCode,string _parentCode,string _urlCode,string _accCode,
          string _roleName,string _roleType,string _enabled,string _metadata) returns(string){
            roleId = roleId + 1;  //递增加1
            /*提供信息的数据存储接口*/
            RoleInfo memory info;
            info.roleId = roleId; //区块链信息自动生成
            info.roleCode = _roleCode;  //岗位CODE
            info.urlCode = _urlCode;  //URLCODE
            info.companyCode = _companyCode;  //岗位名称
            info.parentCode = _parentCode;  //公司ID
            info.roleName = _roleName;  //角色名称
            info.roleType = _roleType;  //角色类型
            info.enabled = _enabled;  //是否启用
            info.metadata = _metadata;  //备用

            info.status = normal; //有效状态
            info.created = now; //记录区块链时间now
            info.lastModifyTime = now; //最后修改时间
            batchAccToRole(_roleCode, _accCode);//角色绑定用户
            /* mapping(string=>positionInfo) roles;  //roleCode=>PositionInfo()*/
            roles[_roleCode] = info;
            //mapping(uint=>string) roleCodes;//positionId=>roleCodes
            roleCodes[roleId] = _roleCode;
            //roleCodesIds push code
            roleCodesIds.push(_roleCode);
            //产生成功事件
            WriteSuccessEvent(roleId.uintToBytes().bytes32ToString());
            return _roleCode;
          }

        /*
          * 查找角色列表
          * @pageNo 开始查询的索引号，即_roleCode
          * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回roleCode在5-10范围的所有用户信息
          * @returns string json//返回所有用户列表的json字符串，管理员使用。
        */
        function queryRoleInfoList(uint pageNo,uint pageSize) returns(string _json){
          uint len = roleCodesIds.length;
          _json = "{\"total\":\"";
          string memory list = "";
          uint ignoreRecords = (pageNo-1)*pageSize;  //需要忽略的记录数
          uint totalRecords = 0; //总记录数
          bool inited = false;
          if(len > 0){
            for(uint i=0; i<len; ++i) {
                RoleInfo info = roles[roleCodesIds[i]];
                totalRecords++;
                if((totalRecords > ignoreRecords) && (totalRecords < (ignoreRecords+pageSize+1))) {
                  pairs.clear();
                  pairs.insert("roleId",info.roleId.uintToBytes().bytes32ToString());
                  pairs.insert("roleCode",info.roleCode);//角色CODE
                  pairs.insert("companyCode",info.companyCode);//公司CODE
                  pairs.insert("parentCode",info.parentCode);//父Code
                  pairs.insert("urlCode",info.urlCode);//urlCode
                  pairs.insert("unBindUrlCode", info.unBindUrlCode);//解绑的菜单code
                  pairs.insert("roleName",info.roleName);//角色名称
                  pairs.insert("roleType",info.roleType);//角色类型
                  pairs.insert("enabled",info.enabled);//是否启用
                  pairs.insert("metadata",info.metadata);//备用
                  pairs.insert("status",info.status);//状态
                  pairs.insert("created",info.created.uintToBytes().bytes32ToString());
                  pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());
                  string memory accJson = pairs.stringTo(false);
                  if(inited) {
                      list = list.toSlice().concat(",".toSlice());
                  }
                  list = list.toSlice().concat(accJson.toSlice());
                  inited = true;
                }
            }
          }
          _json = _json.toSlice().concat(totalRecords.uintToBytes().bytes32ToString().toSlice());
          _json = _json.toSlice().concat("\",\"list\":[".toSlice());
          _json = _json.toSlice().concat(list.toSlice());
          _json = _json.toSlice().concat("]}".toSlice());
          return _json;
        }

        /*
          *查找单个详情
          *@param string _roleCode,//查询的条件
          *@returns string
        */
        function queryRoleInfo(string _roleCode) returns(string _json){
          string memory object = "";
          string memory pairsJson = "";
          RoleInfo info = roles[_roleCode];
          if(!(info.roleCode.toSlice().empty())){
            pairs.clear();
            pairs.insert("roleId",info.roleId.uintToBytes().bytes32ToString());
            pairs.insert("roleCode",info.roleCode);//角色CODE
            pairs.insert("companyCode",info.companyCode);//公司CODE
            pairs.insert("parentCode",info.parentCode);//父Code
            pairs.insert("urlCode",info.urlCode);//urlCode
            pairs.insert("unBindUrlCode", info.unBindUrlCode);//解绑的菜单code
            pairs.insert("roleName",info.roleName);//角色名称
            pairs.insert("roleType",info.roleType);//角色类型
            pairs.insert("enabled",info.enabled);//是否启用
            pairs.insert("metadata",info.metadata);//备用
            pairs.insert("status",info.status);//状态
            pairs.insert("created",info.created.uintToBytes().bytes32ToString());
            pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());
            pairsJson = pairs.stringTo(false);
          }
          object = object.toSlice().concat(pairsJson.toSlice());
          _json = _json.toSlice().concat(object.toSlice());
          return _json;
        }

        /*
          * 删除一条信息
          * @param  uint _roleCode,//用户Id
          * @returns(bool)//是否成功
        */
        function delRoleInfo(string _roleCode) returns(bool _success){
          _success = false;
          if(!(_roleCode.toSlice().empty())){//传进来的参数不是空才修改
              roles[_roleCode].status = cancel; //无效状态
              roles[_roleCode].lastModifyTime = now; //当前记录修改时间
              _success = true;
          }
          //产生成功事件
          WriteSuccessEvent("WriteSuccess");
          return _success;
        }

        /*
         * 修改一条信息
         * @param  uint _roleCode,//编号
         * @returns(bool)
       */
       function modRoleInfo(string _roleCode, string _urlCode,string _roleName,string _metadata) returns(bool){
         if(_roleCode.toSlice().empty()){//传进来的参数为空就表示当前数据不能修改
           return false;
         }
         if(!(_urlCode.toSlice().empty())){//传进来的参数不是空才修改
           roles[_roleCode].urlCode = _urlCode;//_urlCode
         }
         if(!(_roleName.toSlice().empty())){//传进来的参数不是空才修改
           roles[_roleCode].roleName = _roleName;//名称
         }
         if(!(_metadata.toSlice().empty())){//传进来的参数不是空才修改
           roles[_roleCode].metadata = _metadata;//自定义字段
         }
         //最后修改时间
         roles[_roleCode].lastModifyTime = now;
         //产生成功事件
         WriteSuccessEvent("WriteSuccess");
         return true;//返回修改成功
       }

       /*
        * 菜单加入角色内保存到数据库
        * @param  uint _roleCode,//编号
        * @returns(bool)
      */
      function batchUrlToRole(string _roleCode, string _urlCode) returns(bool){
        if(_roleCode.toSlice().empty()){//传进来的参数为空就表示当前数据不能修改
          return false;
        }
        if(!(_urlCode.toSlice().empty())){//传进来的参数不是空才修改
          roles[_roleCode].urlCode = _urlCode;//_urlCode
          roles[_roleCode].lastModifyTime = now;
        }
        //产生成功事件
        WriteSuccessEvent("WriteSuccess");
        return true;//返回修改成功
      }

    function batchUrl(string _batchCode, string _urlCode) returns(bool){

    }

      /*
       * 用户加入角色内
       * @param  uint _roleCode,//编号
       * @returns(bool)
     */
     function batchAccToRole(string _roleCode, string _accCode) returns(bool){
       if(_accCode.toSlice().empty() || _roleCode.toSlice().empty()){
         return false;
       }

       var infoSlice = _accCode.toSlice();
       var infoSlice1 = _accCode.toSlice();
       string memory parts;
       /*定义切片变量*/
       var delim = "|".toSlice();
       for(uint i = 0; i < infoSlice1.count(delim)+1; i++) {
           if(infoSlice.contains(delim)){
                 parts = infoSlice.split(delim).toString();
           }else{
                 parts = infoSlice.toString();
           }
           accs[parts].roleCode = _roleCode;
           //最后修改时间
           accs[parts].lastModifyTime = now;
       }
       //产生成功事件
       WriteSuccessEvent("WriteSuccess");
       return true;//返回修改成功
     }
    //=========================角色信息======end==================================


    //=========================岗位信息======begin==================================
	uint positionId = 0;//递增生成,用户记录在区块链里的唯一标示号(维护的岗位信息)
        /*
          * 添加一条岗位信息
          * @param  string _content,//信息内容，交易参数以"|"分割
          * @参数顺序：positionCode|positionName|companyCode|deptCode|parentId|metadata
          * @returns(uint)//生成的ID
        */
        function addPositionInfo(string _positionCode,string _positionName,string _companyCode,
          string _deptCode,string _parentCode,string _metadata) returns(string){
            //递增加1
            positionId = positionId + 1;
            /*提供岗位信息的数据存储接口*/
            PositionInfo memory info;
            //uint positionId;//区块链信息自动生成
            info.positionId = positionId;
            info.positionCode = _positionCode;  //岗位CODE
            info.positionName = _positionName;  //岗位名称
            info.companyCode = _companyCode;  //公司Code
            info.deptCode = _deptCode;  //部门Code
            info.parentCode = _parentCode;  //父Code
            info.metadata = _metadata;  //备用
            info.status = normal; //有效状态
            info.created = now; //记录区块链时间now
            info.lastModifyTime = now; //最后修改时间
            /* mapping(string=>positionInfo) positions;  //positionCode=>PositionInfo()*/
            positions[_positionCode] = info;
            //mapping(uint=>string) positionCodes;//positionCode=>positionCodes
            positionCodes[positionId] = _positionCode;
            //positionCodeIds push code
            positionCodeIds.push(_positionCode);
            //产生成功事件
            WriteSuccessEvent(positionId.uintToBytes().bytes32ToString());
            return _positionCode;
          }

        /*
          * 查找岗位列表
          * @pageNo 开始查询的索引号，即用户positionCode
          * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回positionCode在5-10范围的所有用户信息
          * @returns string json//返回所有用户列表的json字符串，管理员使用。
        */
        function queryPositionList(uint pageNo,uint pageSize) returns(string _json){
          uint len = positionCodeIds.length;
          _json = "{\"total\":\"";
          string memory list = "";
          uint ignoreRecords = (pageNo-1)*pageSize;  //需要忽略的记录数
          uint totalRecords = 0; //总记录数
          bool inited = false;
          if(len > 0){
            for(uint i=0; i<len; ++i) {
                PositionInfo info = positions[positionCodeIds[i]];
                totalRecords++;
                if((totalRecords > ignoreRecords) && (totalRecords < (ignoreRecords+pageSize+1))) {
                  pairs.clear();
                  pairs.insert("positionId",info.positionId.uintToBytes().bytes32ToString());
                  pairs.insert("positionCode",info.positionCode);//岗位CODE
                  pairs.insert("positionName",info.positionName);//岗位名称
                  pairs.insert("companyCode",info.companyCode);//公司ID
                  pairs.insert("deptCode",info.deptCode);//部门ID
                  pairs.insert("parentCode",info.parentCode);//父ID
                  pairs.insert("urlCode",info.urlCode);//urlCode
                  pairs.insert("unBindUrlCode", info.unBindUrlCode);//解绑的菜单code
                  pairs.insert("metadata",info.metadata);//备用
                  pairs.insert("status",info.status);//岗位状态
                  pairs.insert("created",info.created.uintToBytes().bytes32ToString());
                  pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());
                  string memory accJson = pairs.stringTo(false);
                  if(inited) {
                      list = list.toSlice().concat(",".toSlice());
                  }
                  list = list.toSlice().concat(accJson.toSlice());
                  inited = true;
                }
            }
          }
          _json = _json.toSlice().concat(totalRecords.uintToBytes().bytes32ToString().toSlice());
          _json = _json.toSlice().concat("\",\"list\":[".toSlice());
          _json = _json.toSlice().concat(list.toSlice());
          _json = _json.toSlice().concat("]}".toSlice());
          return _json;
        }

        /*
          *查找单个详情
          *@param string _productId,//查询的条件
          *@returns string
        */
        function queryPositionInfo(string _positionCode) returns(string _json){
          string memory object = "";
          string memory pairsJson = "";
          PositionInfo info = positions[_positionCode];
          if(!(info.positionCode.toSlice().empty())){
            pairs.clear();
            pairs.insert("positionId" , info.positionId.uintToBytes().bytes32ToString());//区块链自动生成
            pairs.insert("positionCode" , info.positionCode);//岗位CODE
            pairs.insert("positionName" , info.positionName);//岗位名称
            pairs.insert("companyCode" , info.companyCode);//公司Code
            pairs.insert("deptCode" , info.deptCode);//部门Code
            pairs.insert("parentCode",info.parentCode);//父Code
            pairs.insert("urlCode",info.urlCode);//urlCode
            pairs.insert("unBindUrlCode", info.unBindUrlCode);//解绑的菜单code
            pairs.insert("metadata" , info.metadata);//备注说明
            pairs.insert("status",info.status);//岗位状态
            pairs.insert("created",info.created.uintToBytes().bytes32ToString());
            pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());
            pairsJson = pairs.stringTo(false);
          }
          object = object.toSlice().concat(pairsJson.toSlice());
          _json = _json.toSlice().concat(object.toSlice());
          return _json;
        }

        /*
          * 删除一条岗位信息
          * @param  uint _positionCode,//用户Id
          * @returns(bool)//是否成功
        */
        function delPositionInfo(string _positionCode) returns(bool _success){
          _success = false;
          if(!(_positionCode.toSlice().empty())){//传进来的参数不是空才修改
              positions[_positionCode].status = cancel; //无效状态
              positions[_positionCode].lastModifyTime = now; //当前记录修改时间
              _success = true;
          }
          //产生成功事件
          WriteSuccessEvent("WriteSuccess");
          return _success;
        }

        /*
         * 修改一条岗位信息
         * @param  uint _positionCode,//编号
         * @returns(bool)
       */
       function modPositionInfo(string _positionCode, string _positionName,string _metadata) returns(bool){
         if(_positionCode.toSlice().empty()){//传进来的参数为空就表示当前数据不能修改
           return false;
         }
         if(!(_positionName.toSlice().empty())){//传进来的参数不是空才修改
           positions[_positionCode].positionName = _positionName;//岗位名称
         }
         if(!(_metadata.toSlice().empty())){//传进来的参数不是空才修改
           positions[_positionCode].metadata = _metadata;//自定义字段
         }
         //最后修改时间
         positions[_positionCode].lastModifyTime = now;
         //产生成功事件
         WriteSuccessEvent("WriteSuccess");
         return true;//返回修改成功
       }
    //=========================岗位信息======end==================================

    //=========================部门信息======begin==================================
    uint deptId = 0;//递增生成,部门记录在区块链里的唯一标示号(部门信息)
    /*
      * 添加一条部门信息
      * @param
      * @参数顺序：deptCode|parentCode|companyCode|depName|metadata，即部门CODE|上级Code|公司Code|部门名称|备注
      * @returns(uint)//生成的Code
    */
    function addDeptInfo(string _content) returns(string _deptCode){
      deptId++;
      var infoSlice = _content.toSlice();
      /*定义切片变量*/
      var delim = "|".toSlice();
      /*提供用户信息的数据存储接口*/
      DeptInfo memory deptinfo;
      deptinfo.deptId = deptId;//区块链自动生成
      deptinfo.deptCode = infoSlice.split(delim).toString(); //部门CODE
      deptinfo.parentCode = infoSlice.split(delim).toString(); //上级Code
      deptinfo.companyCode = infoSlice.split(delim).toString(); //公司Code
      deptinfo.depName = infoSlice.split(delim).toString(); //部门名称
      deptinfo.metadata = infoSlice.split(delim).toString(); //标记信息是否可用，CANCEL为不可用
      deptinfo.created = now; //创建用户信息 记录区块链时间now
      deptinfo.lastModifyTime = now; //最后修改时间now
      deptinfo.status = normal; //创建用户信息 记录区块链时间now
      _deptCode = deptinfo.deptCode;
      deptInfos[_deptCode] = deptinfo;
      deptCodes.push(_deptCode);

      //产生成功事件
      WriteSuccessEvent(_deptCode);
      return _deptCode;
    }

    /*
      * 查找部门列表
      * @pageNo 开始查询的索引号
      * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
      * @returns string json//返回所有部门列表的json字符串，管理员使用。
    */
    function queryDeptInfoList(uint _pageNo,uint _pageSize) returns(string _json){
      uint len = deptCodes.length;
      _json = "{\"total\":\"";
      string memory list = "";
      uint ignoreRecords = (_pageNo-1)*_pageSize;  //需要忽略的记录数
      uint totalRecords = 0; //总记录数
      bool inited = false;
      if(len > 0){
        for(uint i=0; i<len; ++i) {
          DeptInfo deptinfo = deptInfos[deptCodes[i]];
          totalRecords++;
          if((totalRecords > ignoreRecords) && (totalRecords < (ignoreRecords+_pageSize+1))) {
            pairs.clear();
            pairs.insert("deptCode",deptinfo.deptCode);//部门CODE
            pairs.insert("parentCode",deptinfo.parentCode);//上级Code
            pairs.insert("companyCode",deptinfo.companyCode);//公司Code
            pairs.insert("depName",deptinfo.depName);//部门名称
            pairs.insert("metadata",deptinfo.metadata);//自定义字段
            pairs.insert("status",deptinfo.status);//用户状态
            pairs.insert("urlCode",deptinfo.urlCode);//urlCode
            pairs.insert("unBindUrlCode", deptinfo.unBindUrlCode);//解绑的菜单code
            pairs.insert("created",deptinfo.created.uintToBytes().bytes32ToString());
            pairs.insert("lastModifyTime",deptinfo.lastModifyTime.uintToBytes().bytes32ToString());

            string memory deptJson = pairs.stringTo(false);
            if(inited) {
                list = list.toSlice().concat(",".toSlice());
            }
            list = list.toSlice().concat(deptJson.toSlice());
            inited = true;
          }
        }
      }
      _json = _json.toSlice().concat(totalRecords.uintToBytes().bytes32ToString().toSlice());
      _json = _json.toSlice().concat("\",\"list\":[".toSlice());
      _json = _json.toSlice().concat(list.toSlice());
      _json = _json.toSlice().concat("]}".toSlice());
      return _json;
    }

    /*
      * 查找部门详情
      * @deptCode 部门唯一编码
      * @returns string json//返回所有部门详情的json字符串。
    */
    function queryDeptInfo(string _deptCode) returns(string _json){
      string memory object = "";
      //先用accId查询，
      DeptInfo deptinfo = deptInfos[_deptCode];
      if(!(deptinfo.deptCode.toSlice().empty())){
          pairs.clear();
          pairs.insert("deptCode",_deptCode);//部门CODE
          pairs.insert("parentCode",deptinfo.parentCode);//上级Code
          pairs.insert("companyCode",deptinfo.companyCode);//公司Code
          pairs.insert("urlCode",deptinfo.urlCode);//urlCode
          pairs.insert("unBindUrlCode", deptinfo.unBindUrlCode);//解绑的菜单code
          pairs.insert("depName",deptinfo.depName);//部门名称
          pairs.insert("metadata",deptinfo.metadata);//自定义字段
          pairs.insert("status",deptinfo.status);//用户状态
          pairs.insert("created",deptinfo.created.uintToBytes().bytes32ToString());
          pairs.insert("lastModifyTime",deptinfo.lastModifyTime.uintToBytes().bytes32ToString());

          string memory accJson = pairs.stringTo(false);

      } else {
          _json = "";
      }
      object = object.toSlice().concat(accJson.toSlice());
      _json = _json.toSlice().concat(object.toSlice());
      return _json;
    }

    /*
      * 修改一条部门信息
      * @param
      * @参数顺序：deptCode|parentCode|companyCode|depName|metadata，即部门CODE|上级Code|公司Code|部门名称|备注
      * @returns(bool) 是否修改成功
    */
    function modDeptInfo(string _content) returns(bool){
      var infoSlice = _content.toSlice();
      /*定义切片变量*/
      var delim = "|".toSlice();
      /*提供用户信息的数据存储接口*/
      DeptInfo memory deptinfo;
      deptinfo.deptCode = infoSlice.split(delim).toString(); //部门CODE
      deptinfo.depName = infoSlice.split(delim).toString(); //部门名称
      deptinfo.metadata = infoSlice.split(delim).toString(); //备注
      deptinfo.created = now; //创建用户信息 记录区块链时间now
      deptinfo.status = normal; //创建用户信息 记录区块链时间now

      if(!(deptinfo.depName.toSlice().empty())){//传进来的参数不是空才修改
        deptInfos[deptinfo.deptCode].depName = deptinfo.depName;//部门名称
      }
      if(!(deptinfo.metadata.toSlice().empty())){//传进来的参数不是空才修改
        deptInfos[deptinfo.deptCode].metadata = deptinfo.metadata;//备注
      }
      deptInfos[deptinfo.deptCode].lastModifyTime = now;//最后修改时间

      //产生成功事件
      WriteSuccessEvent("success");
      return true;
    }

    /*
      * 删除部门
      * @deptCode 部门唯一编码
      * @returns(bool) 是否删除成功
    */
    function delDeptInfo(string _deptCode) returns(bool){
  		if(!(deptInfos[_deptCode].status.toSlice().empty())){//传进来的参数不是空才修改
  			  deptInfos[_deptCode].status = cancel;//标记信息是否可用，CANCEL为不可用
  			  deptInfos[_deptCode].lastModifyTime = now; //当前记录修改时间
          //产生成功事件
          WriteSuccessEvent("success");
          return true;
  		}else{
        //产生失败事件
        WriteFailEvent("failed");
        return false;
      }
    }

    //=========================关联查询======start==================================

    /*
      * 查找部门下面所有岗位列表
      * @pageNo 开始查询的索引号
      * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
      * @returns string json//返回所有部门列表的json字符串，管理员使用。
    */
    function queryDeptToPositionList(string _deptCode, uint _pageNo,uint _pageSize) returns(string _json){
        uint len = positionCodeIds.length;
        _json = "{\"total\":\"";
        string memory list = "";
        uint ignoreRecords = (_pageNo-1)*_pageSize;  //需要忽略的记录数
        uint totalRecords = 0; //总记录数
        bool inited = false;
        if(len > 0){
          for(uint i=0; i<len; ++i) {
            PositionInfo info = positions[positionCodeIds[i]];
            if(Strings.equals(info.deptCode.toSlice(), _deptCode.toSlice())){
              totalRecords++;
              if((totalRecords > ignoreRecords) && (totalRecords < (ignoreRecords+_pageSize+1))) {
                pairs.clear();
                pairs.insert("positionId",info.positionId.uintToBytes().bytes32ToString());
                pairs.insert("positionCode",info.positionCode);//岗位CODE
                pairs.insert("positionName",info.positionName);//岗位名称
                pairs.insert("companyCode",info.companyCode);//公司ID
                pairs.insert("deptCode",info.deptCode);//部门ID
                pairs.insert("parentCode",info.parentCode);//父ID
                pairs.insert("metadata",info.metadata);//备用
                pairs.insert("status",info.status);//岗位状态
                pairs.insert("created",info.created.uintToBytes().bytes32ToString());
                pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());

                string memory deptJson = pairs.stringTo(false);
                if(inited) {
                    list = list.toSlice().concat(",".toSlice());
                }
                list = list.toSlice().concat(deptJson.toSlice());
                inited = true;
              }
            }
          }
        }
        _json = _json.toSlice().concat(totalRecords.uintToBytes().bytes32ToString().toSlice());
        _json = _json.toSlice().concat("\",\"list\":[".toSlice());
        _json = _json.toSlice().concat(list.toSlice());
        _json = _json.toSlice().concat("]}".toSlice());
        return _json;
    }

    /*
      * 查找部门下面所有员工列表
      * @pageNo 开始查询的索引号
      * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
      * @returns string json//返回所有部门列表的json字符串，管理员使用。
    */
    function queryDeptToAccList(string _deptCode, uint _pageNo,uint _pageSize) returns(string _json){
      uint len = accCodes.length;
      _json = "{\"total\":\"";
      string memory list = "";
      uint ignoreRecords = (_pageNo-1)*_pageSize;  //需要忽略的记录数
      uint totalRecords = 0; //总记录数
      bool inited = false;
      if(len > 0){
        for(uint i=0; i<len; ++i) {
          AccInfo info = accs[accCodes[i]];
          if(Strings.equals(info.deptCode.toSlice(), _deptCode.toSlice())){
            totalRecords++;
            if((totalRecords > ignoreRecords) && (totalRecords < (ignoreRecords+_pageSize+1))) {
              pairs.clear();
              pairs.insert("accId",info.accId.uintToBytes().bytes32ToString());
              pairs.insert("accCode",info.accCode);//用户CODE
              pairs.insert("account",info.account);//账户
              pairs.insert("userName",info.userName);//账户名
              pairs.insert("password",info.password);//账户密码
              pairs.insert("companyCode",info.companyCode);//公司CODE
              pairs.insert("depName", deptInfos[info.deptCode].depName);//部门名称
              pairs.insert("deptCode",info.deptCode);//部门CODE
              pairs.insert("positionCode",info.positionCode);//岗位CODE
              pairs.insert("positionName", positions[info.positionCode].positionName);//部门名称
              pairs.insert("roleCode", info.roleCode);//角色Code
              pairs.insert("roleName", roles[info.roleCode].roleName);//角色名称
              pairs.insert("email",info.email);//邮箱
              pairs.insert("mobile",info.mobile);//联系方式
              pairs.insert("enabled",info.enabled);//是否禁用

              pairs.insert("tradeNo",info.tradeNo);//凭据号,开发者需要保证其唯一，与业务系统关联
              pairs.insert("metadata",info.metadata);//自定义字段
              pairs.insert("hdAddress",info.hdAddress);//区块链账户公钥地址
              pairs.insert("status",info.status);//用户状态
              pairs.insert("created",info.created.uintToBytes().bytes32ToString());
              pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());

              string memory deptJson = pairs.stringTo(false);
              if(inited) {
                  list = list.toSlice().concat(",".toSlice());
              }
              list = list.toSlice().concat(deptJson.toSlice());
              inited = true;
            }
          }
        }
      }
      _json = _json.toSlice().concat(totalRecords.uintToBytes().bytes32ToString().toSlice());
      _json = _json.toSlice().concat("\",\"list\":[".toSlice());
      _json = _json.toSlice().concat(list.toSlice());
      _json = _json.toSlice().concat("]}".toSlice());
      return _json;
    }

    /*
      * 查找岗位下面所有员工列表
      * @pageNo 开始查询的索引号
      * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
      * @returns string json//返回所有部门列表的json字符串，管理员使用。
    */
    function queryPositionToAccList(string _positionCode, uint _pageNo,uint _pageSize) returns(string _json){
      uint len = accCodes.length;
      _json = "{\"total\":\"";
      string memory list = "";
      uint ignoreRecords = (_pageNo-1)*_pageSize;  //需要忽略的记录数
      uint totalRecords = 0; //总记录数
      bool inited = false;
      if(len > 0){
        for(uint i=0; i<len; ++i) {
          AccInfo info = accs[accCodes[i]];
          if(Strings.equals(info.positionCode.toSlice(), _positionCode.toSlice())){
            totalRecords++;
            if((totalRecords > ignoreRecords) && (totalRecords < (ignoreRecords+_pageSize+1))) {
              pairs.clear();
              pairs.insert("accId",info.accId.uintToBytes().bytes32ToString());
              pairs.insert("accCode",info.accCode);//用户CODE
              pairs.insert("account",info.account);//账户
              pairs.insert("userName",info.userName);//账户名
              pairs.insert("password",info.password);//账户密码
              pairs.insert("companyCode",info.companyCode);//公司CODE
              pairs.insert("depName", deptInfos[info.deptCode].depName);//部门名称
              pairs.insert("deptCode",info.deptCode);//部门CODE
              pairs.insert("positionCode",info.positionCode);//岗位CODE
              pairs.insert("positionName", positions[info.positionCode].positionName);//部门名称
              pairs.insert("roleCode", info.roleCode);//角色Code
              pairs.insert("roleName", roles[info.roleCode].roleName);//角色名称
              pairs.insert("email",info.email);//邮箱
              pairs.insert("mobile",info.mobile);//联系方式
              pairs.insert("enabled",info.enabled);//是否禁用

              pairs.insert("tradeNo",info.tradeNo);//凭据号,开发者需要保证其唯一，与业务系统关联
              pairs.insert("metadata",info.metadata);//自定义字段
              pairs.insert("hdAddress",info.hdAddress);//区块链账户公钥地址
              pairs.insert("status",info.status);//用户状态
              pairs.insert("created",info.created.uintToBytes().bytes32ToString());
              pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());

              string memory deptJson = pairs.stringTo(false);
              if(inited) {
                  list = list.toSlice().concat(",".toSlice());
              }
              list = list.toSlice().concat(deptJson.toSlice());
              inited = true;
            }
          }
        }
      }
      _json = _json.toSlice().concat(totalRecords.uintToBytes().bytes32ToString().toSlice());
      _json = _json.toSlice().concat("\",\"list\":[".toSlice());
      _json = _json.toSlice().concat(list.toSlice());
      _json = _json.toSlice().concat("]}".toSlice());
      return _json;
    }

    /*
      * 查找角色下面所有员工
      * @pageNo 开始查询的索引号
      * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
      * @returns string json//返回所有部门列表的json字符串，管理员使用。
    */
    function querRoleToAccList(string _roleCode, uint _pageNo,uint _pageSize) returns(string _json){
      uint len = accCodes.length;
      _json = "{\"total\":\"";
      string memory list = "";
      uint ignoreRecords = (_pageNo-1)*_pageSize;  //需要忽略的记录数
      uint totalRecords = 0; //总记录数
      bool inited = false;
      if(len > 0){
        for(uint i=0; i<len; ++i) {
          AccInfo info = accs[accCodes[i]];
          if(Strings.equals(info.roleCode.toSlice(), _roleCode.toSlice())){
            totalRecords++;
            if((totalRecords > ignoreRecords) && (totalRecords < (ignoreRecords+_pageSize+1))) {
              pairs.clear();
              pairs.insert("accId",info.accId.uintToBytes().bytes32ToString());
              pairs.insert("accCode",info.accCode);//用户CODE
              pairs.insert("account",info.account);//账户
              pairs.insert("userName",info.userName);//账户名
              pairs.insert("password",info.password);//账户密码
              pairs.insert("companyCode",info.companyCode);//公司CODE
              pairs.insert("depName", deptInfos[info.deptCode].depName);//部门名称
              pairs.insert("deptCode",info.deptCode);//部门CODE
              pairs.insert("positionCode",info.positionCode);//岗位CODE
              pairs.insert("positionName", positions[info.positionCode].positionName);//部门名称
              pairs.insert("roleCode", info.roleCode);//角色Code
              pairs.insert("roleName", roles[info.roleCode].roleName);//角色名称
              pairs.insert("email",info.email);//邮箱
              pairs.insert("mobile",info.mobile);//联系方式
              pairs.insert("enabled",info.enabled);//是否禁用

              pairs.insert("tradeNo",info.tradeNo);//凭据号,开发者需要保证其唯一，与业务系统关联
              pairs.insert("metadata",info.metadata);//自定义字段
              pairs.insert("hdAddress",info.hdAddress);//区块链账户公钥地址
              pairs.insert("status",info.status);//用户状态
              pairs.insert("created",info.created.uintToBytes().bytes32ToString());
              pairs.insert("lastModifyTime",info.lastModifyTime.uintToBytes().bytes32ToString());

              string memory deptJson = pairs.stringTo(false);
              if(inited) {
                  list = list.toSlice().concat(",".toSlice());
              }
              list = list.toSlice().concat(deptJson.toSlice());
              inited = true;
            }
          }
        }
      }
      _json = _json.toSlice().concat(totalRecords.uintToBytes().bytes32ToString().toSlice());
      _json = _json.toSlice().concat("\",\"list\":[".toSlice());
      _json = _json.toSlice().concat(list.toSlice());
      _json = _json.toSlice().concat("]}".toSlice());
      return _json;
    }

    //=========================关联查询======end==================================

    //=========================权限绑定/解绑======start==================================

    /*
      * 关联菜单
      * @_urlCodes 绑定的菜单
      * @_unBindUrlCodes 没绑定的菜单
      * @_bindCode 关联code
      * @returns
    */
    function bindUrl(string _urlCodes, string _unBindUrlCodes, string _bindCode) returns(bool){
        if (Strings.contains(_bindCode.toSlice(), "acc".toSlice())) {
            accs[_bindCode].urlCode = _urlCodes;
            accs[_bindCode].unBindUrlCode = _unBindUrlCodes;
            accs[_bindCode].lastModifyTime = now;
        }else if (Strings.contains(_bindCode.toSlice(), "dept".toSlice())) {
            deptInfos[_bindCode].urlCode = _urlCodes;
            deptInfos[_bindCode].unBindUrlCode = _unBindUrlCodes;
            deptInfos[_bindCode].lastModifyTime = now;
        }else if (Strings.contains(_bindCode.toSlice(), "pos".toSlice())) {
            positions[_bindCode].urlCode = _urlCodes;
            positions[_bindCode].unBindUrlCode = _unBindUrlCodes;
            positions[_bindCode].lastModifyTime = now;
        }else if (Strings.contains(_bindCode.toSlice(), "dept".toSlice())) {
            roles[_bindCode].urlCode = _urlCodes;
            roles[_bindCode].unBindUrlCode = _unBindUrlCodes;
            roles[_bindCode].lastModifyTime = now;
        }else{
            WriteFailEvent("绑定失败");
            return false;
        }
        WriteSuccessEvent("绑定成功");
        return true;
    }

}
