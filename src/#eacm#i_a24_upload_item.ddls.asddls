@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interfaccia upload items A24'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_A24_UPLOAD_ITEM
  as select from /eacm/a24logi
  association to parent /EACM/I_A24_UPLOAD as _Upload on $projection.Requestid = _Upload.Requestid
{
  key requestid as Requestid,
  key zlineno   as Zlineno,
      status    as Status,
      message   as Message,
      record    as Record,
      _Upload
}
