//@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'oData Request'
//@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_A24_REQ_QRY'
define root custom entity /EACM/A24Request
  //composition of target_data_source_name as _association_name
{
  key RequestId   : sysuuid_x16;
//      created_by  : abp_creation_user;
      ProcessedAt : abp_locinst_lastchange_tstmpl;
      Items       : composition [1..*] of /EACM/A24Items;
}
