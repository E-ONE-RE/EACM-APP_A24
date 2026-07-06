@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interfaccia upoad items A24'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/C_A24_UPLOAD_ITEM
//  provider contract transactional_query
  as projection on /EACM/I_A24_UPLOAD_ITEM
{
  key Requestid,
  key Zlineno,
      Status,
      Message,
      Record,
      _Upload : redirected to parent /EACM/C_A24_UPLOAD
}
