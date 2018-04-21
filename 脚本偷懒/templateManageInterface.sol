/**
 * 提供合约接口
 */
contract AuthManageInterface{



  //=========================用户信息======begin==================================
  /*
    * 添加一条信息
    * @param
    * @参数顺序：user_name|password|trade_no|metadata|hdAddress|privateKey，即用户名|密码|业务流水单号|备注信息|公钥|私钥
    * @returns(uint)//生成的ID
  */
  function addAccInfo(string _txContent) returns(uint);

      /*
        * 查找列表
        * @pageNo 开始查询的索引号，即用户accId
        * @pageSize 分页Size  如 accId=5,pageSize=10，那么返回accId在5-14范围的所有用户信息
        * @returns string json//返回所有用户列表的json字符串，管理员使用。
      */
      function queryAccList(uint pageNo,uint pageSize) returns(string _json);

      /*
        *查找单个详情
        *@param uint _accCode,//用户CODE
        *@param string _hdAddress,//区块链账户地址 （accId不为空则以accId查询，否则用hdAddress查询）
        *@returns string
      */
      function queryAccInfo(string _accCode, string _hdAddress) returns(string _json);

      /*
        * 删除一条信息
        * @param  string _accCode,//用户CODE
        * @returns(bool)//是否成功
      */
      function delAccInfo(string _accCode) returns(bool _success);

      /*
       * 修改一条信息
       * @param  string _accCode,//用户CODE
       * @param  string _content,//用户信息内容,多个参数按顺序以"|"相隔离。判断每一个参数值是否为空，为空则不修改
       * @returns(bool)
     */
     function modAccInfo(string _accCode, string _content) returns(bool);

     /*
      * 批量分配用户的部门岗位或者角色
      * @param  string _deptCode,//部门CODE
      * @param  string _positionCode,//岗位CODE
      * @param  string _roleCode,//角色CODE
      * @param  string _accCode,//用户Code，用|分割
      * @returns(bool)
    */
    function batchAccInfo(string _deptCode, string _positionCode, string _accCode, string _roleCode) returns(bool);
     //=========================用户信息======end==================================


  //=========================菜单URL信息======begin==================================
        /*
          * 添加一条信息
          * @param  string _content,//信息内容，交易参数以"|"分割
          * @参数顺序:_urlCode|_parentCode|_systemCode|_companyCode|_name|_url|_icon|_createUser|_metadata
          * @returns(uint)//生成的Code
        */
        function addUrlInfo(string _urlCode,string _parentCode,string _systemCode,string _companyCode,
          string _name,string _url,string _createUser,string _metadata) returns(string);

        /*
          * 查找列表
          * @pageNo 开始查询的索引号，即_roleCode
          * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回urlCode在5-10范围的所有用户信息
          * @returns string json//返回所有用户列表的json字符串，管理员使用。
        */
        function queryUrlInfoList(uint pageNo,uint pageSize) returns(string _json);

        /*
          *查找单个详情
          *@param string _roleCode,//查询的条件
          *@returns string
        */
        function queryUrlInfo(string _urlCode) returns(string _json);

        /*
          * 删除一条信息
          * @param  uint _urlCode,//CODE
          * @returns(bool)//是否成功
        */
        function delUrlInfo(string _urlCode) returns(bool _success);

        /*
         * 修改一条信息
         * @param  uint _urlCode,//编号
         * @returns(bool)
       */
       function modUrlInfo(string _urlCode, string _name,string _url,string _metadata) returns(bool);

    //=========================菜单URL信息======end==================================


//=========================角色信息======begin==================================
      /*
        * 添加一条角色信息
        * @param  string _content,//信息内容，交易参数以"|"分割
        * @参数顺序：_roleCode|_companyCode|_parentCode|_urlCode|_roleName|_roleType|_enabled|_metadata
        * @returns(uint)//生成的Code
      */
      function addRoleInfo(string _roleCode,string _companyCode,string _parentCode,string _urlCode,string _accCode,
        string _roleName,string _roleType,string _enabled,string _metadata) returns(string);

      /*
        * 查找角色列表
        * @pageNo 开始查询的索引号，即_roleCode
        * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回roleCode在5-10范围的所有用户信息
        * @returns string json//返回所有用户列表的json字符串，管理员使用。
      */
      function queryRoleInfoList(uint pageNo,uint pageSize) returns(string _json);

      /*
        *查找单个详情
        *@param string _roleCode,//查询的条件
        *@returns string
      */
      function queryRoleInfo(string _roleCode) returns(string _json);

      /*
        * 删除一条信息
        * @param  uint _roleCode,//角色Code
        * @returns(bool)//是否成功
      */
      function delRoleInfo(string _roleCode) returns(bool _success);

      /*
       * 修改一条信息
       * @param  uint _roleCode,//编号
       * @returns(bool)
     */
     function modRoleInfo(string _roleCode, string _urlCode,string _roleName,string _metadata) returns(bool);

     /*
      * 菜单加入角色内保存到数据库
      * @param  uint _roleCode,//编号
      * @returns(bool)
    */
    function batchUrlToRole(string _roleCode, string _urlCode) returns(bool);

    /*
     * 用户加入角色内
     * @param  uint _roleCode,//编号
     * @returns(bool)
   */
   function batchAccToRole(string _roleCode, string _accCode) returns(bool);

  //=========================角色信息======end==================================


  //=========================岗位信息======begin==================================
      /*
        * 添加一条信息
        * @param  string _content,//信息内容，交易参数以"|"分割
        * @参数顺序：positionCode|positionName|companyCode|deptCode|parentCode|metadata
        * @returns(uint)//生成的Code
      */
      function addPositionInfo(string _positionCode,string _positionName,string _companyCode,
        string _deptCode,string _parentCode,string _metadata) returns(string);

      /*
        * 查找列表
        * @pageNo 开始查询的索引号，即用户positionCode
        * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回positionCode在5-10范围的所有用户信息
        * @returns string json//返回所有用户列表的json字符串，管理员使用。
      */
      function queryPositionList(uint pageNo,uint pageSize) returns(string _json);

      /*
        *查找单个详情
        *@param string _positionCode,//查询的条件
        *@returns string
      */
      function queryPositionInfo(string _positionCode) returns(string _json);

      /*
        * 删除一条信息
        * @param  uint _positionCode,//用户Id
        * @returns(bool)//是否成功
      */
      function delPositionInfo(string _positionCode) returns(bool _success);

      /*
       * 修改一条信息
       * @param  uint _positionCode,//编号
       * @returns(bool)
     */
     function modPositionInfo(string _positionCode, string _positionName, string _metadata) returns(bool);

  //=========================岗位信息======end==================================

//=========================部门信息======begin==================================
/*
  * 添加一条部门信息
  * @param
  * @参数顺序：deptCode|parentCode|companyCode|depName|metadata，即部门CODE|上级Code|公司Code|部门名称|备注
  * @returns string _deptCode 部门CODE
*/
function addDeptInfo(string _content) returns(string _deptCode);

/*
  * 查找部门列表
  * @pageNo 开始查询的索引号
  * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
  * @returns string json//返回所有部门列表的json字符串，管理员使用。
*/
function queryDeptInfoList(uint _pageNo,uint _pageSize) returns(string _json);

/*
  * 查找部门详情
  * @deptCode 部门唯一编码
  * @returns string json//返回所有部门详情的json字符串。
*/
function queryDeptInfo(string _deptCode) returns(string _json);

/*
  * 修改一条部门信息
  * @param
  * @参数顺序：deptCode|parentCode|companyCode|depName|metadata，即部门CODE|上级Code|公司Code|部门名称|备注
  * @returns(bool) 是否修改成功
*/
function modDeptInfo(string _content) returns(bool);

/*
  * 删除部门
  * @deptCode 部门唯一编码
  * @returns(bool) 是否删除成功
*/
function delDeptInfo(string _deptCode) returns(bool);

//=========================部门信息======end==================================

//=========================关联查询======start==================================

/*
  * 查找部门下面所有岗位列表
  * @pageNo 开始查询的索引号
  * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
  * @returns string json//返回所有部门列表的json字符串，管理员使用。
*/
function queryDeptToPositionList(string _deptCode, uint _pageNo,uint _pageSize) returns(string _json);

/*
  * 查找部门下面所有员工列表
  * @pageNo 开始查询的索引号
  * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
  * @returns string json//返回所有部门列表的json字符串，管理员使用。
*/
function queryDeptToAccList(string _deptCode, uint _pageNo,uint _pageSize) returns(string _json);

/*
  * 查找岗位下面所有员工列表
  * @pageNo 开始查询的索引号
  * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
  * @returns string json//返回所有部门列表的json字符串，管理员使用。
*/
function queryPositionToAccList(string _positionCode, uint _pageNo,uint _pageSize) returns(string _json);

/*
  * 查找角色下面所有员工
  * @pageNo 开始查询的索引号
  * @pageSize 分页Size  如 pageNo=5,pageSize=10，那么返回部门信息在5-14范围的所有用户信息
  * @returns string json//返回所有部门列表的json字符串，管理员使用。
*/
function querRoleToAccList(string _roleCode, uint _pageNo,uint _pageSize) returns(string _json);

//=========================关联查询======end==================================

/*
  * 关联菜单
  * @_urlCodes 绑定的菜单
  * @_unBindUrlCodes 没绑定的菜单
  * @_bindCode 关联code
  * @returns string bool
*/
function bindUrl(string _urlCodes, string _unBindUrlCodes, string _bindCode) returns(bool);

    //-------定义事件---------------
    event WriteSuccessEvent(string desc);
    event WriteFailEvent(string desc);

}
