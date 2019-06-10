<#import "/spring.ftl" as spring />
<!doctype html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
  <head>
    <base href="<@spring.url basePath/>">
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Eureka</title>
    <meta name="description" content="">
    <meta name="viewport" content="width=device-width">

    <link rel="stylesheet" href="eureka/css/wro.css">
    <link rel="stylesheet" href="eureka/css/iview.css">

  </head>

  <body id="one">
    <#include "header.ftl">
    <div class="container-fluid xd-container">
      <#include "navbar.ftl">
      <h1>Instances currently registered with Eureka</h1>
      <table id='instances' class="table table-striped table-hover">
        <thead>
          <tr><th>Application</th><th>AMIs</th><th>Availability Zones</th><th>Status</th></tr>
        </thead>
        <tbody id="status">
          <#if apps?has_content>
            <#list apps as app>
              <tr>
                <td><b>${app.name}</b></td>
                <td>
                  <#list app.amiCounts as amiCount>
                    <b>${amiCount.key}</b> (${amiCount.value})<#if amiCount_has_next>,</#if>
                  </#list>
                </td>
                <td>
                  <#list app.zoneCounts as zoneCount>
                    <b>${zoneCount.key}</b> (${zoneCount.value})<#if zoneCount_has_next>,</#if>
                  </#list>
                </td>
                <td>
                  <#list app.instanceInfos as instanceInfo>
                    <#if instanceInfo.isNotUp>
                      <font color=red size=+1><b>
                    </#if>
                    <b>${instanceInfo.status}</b> (${instanceInfo.instances?size}) -
                    <#if instanceInfo.isNotUp>
                      </b></font>
                    </#if>
                    <#list instanceInfo.instances as instance>
                      <#if instance.isHref>
                        <Poptip trigger="hover" >
                          <a href="${instance.url}" target="_blank">${instance.id}</a>
                          <div slot="title"><i>${app.name}-${instance.id}</i></div>
                          <div slot="content">
                            <!--
                            curl -X PUT -i 'http://192.168.8.208:8761/eureka/apps/app-name/ip:port/status?value=DOWN'
                            -->
                              <#if instanceInfo.isNotUp>
                                  <i-button type="success" style="alignment: right" size="large" long
                                            @click="doIt('${app.name}','${instance.id}','UP')">上线
                                  </i-button>
                              <#else>
                                  <i-button type="error" style="alignment: left" size="large" long
                                            @click="doIt('${app.name}','${instance.id}','DOWN')">下线
                                  </i-button>
                              </#if>
                          </div>
                        </Poptip>

                      <#else>
                        ${instance.id}
                      </#if><#if instance_has_next>,</#if>
                    </#list>
                  </#list>
                </td>
              </tr>
            </#list>
          <#else>
            <tr><td colspan="4">No instances available</td></tr>
          </#if>

        </tbody>
      </table>

      <h1>General Info</h1>

      <table id='generalInfo' class="table table-striped table-hover">
        <thead>
          <tr><th>Name</th><th>Value</th></tr>
        </thead>
        <tbody>
          <#list statusInfo.generalStats?keys as stat>
            <tr>
              <td>${stat}</td><td>${statusInfo.generalStats[stat]!""}</td>
            </tr>
          </#list>
          <#list statusInfo.applicationStats?keys as stat>
            <tr>
              <td>${stat}</td><td>${statusInfo.applicationStats[stat]!""}</td>
            </tr>
          </#list>
        </tbody>
      </table>
      <h1>Instance Info</h1>

      <table id='instanceInfo' class="table table-striped table-hover">
        <thead>
          <tr><th>Name</th><th>Value</th></tr>
        <thead>
        <tbody>
          <#list instanceInfo?keys as key>
            <tr>
              <td>${key}</td><td>${instanceInfo[key]!""}</td>
            </tr>
          </#list>
        </tbody>
      </table>
    </div>
    <script type="text/javascript" src="eureka/js/wro.js" ></script>
    <script type="text/javascript" src="eureka/js/vue.js" ></script>
    <script type="text/javascript" src="eureka/js/iview.js" ></script>
    <script type="text/javascript" src="eureka/js/axios.js" ></script>
    <script type="text/javascript">
       $(document).ready(function() {
         $('table.stripeable tr:odd').addClass('odd');
         $('table.stripeable tr:even').addClass('even');
       });

       new Vue({
         el: '#status',
         data: {
           visible: false
         },
         methods: {
           show: function () {
             this.visible = true;
           },
           refresh:function(){
             window.location.reload();
           },
             doIt:function(appName,ipport,status){
               var vue=this;
                 this.$Modal.confirm({
                     title: '确认执行此操作吗???',
                     draggable:true,
                     okText:"确定",
                     cancelText:"取消",
                     maskClosable:true,
                     content: '应用: <strong>'+appName +' </strong><br/> IP:PORT <strong> '+ipport+" </strong> <br/> 目标状态:<strong>"+status+'</strong>',
                     onOk: () => {
                         axios({
                             method: 'put',
                             url:'http://'+window.location.host+'/eureka/apps/'+appName+'/'+ipport+'/status?value='+status
                         })
                             .then((response)=>{
                                 vue.refresh();
                             })
                             .catch((error)=>{
                                 vue.refresh();
                             })
                     },
                     onCancel: () => {
                         vue.refresh();
                     }
                 });
             }
         }
       })
    </script>
  </body>
</html>
