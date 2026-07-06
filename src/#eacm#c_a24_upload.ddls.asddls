@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interfaccia upload A24'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/C_A24_UPLOAD
  provider contract transactional_query
  as projection on /EACM/I_A24_UPLOAD
{
  key Requestid,
      CreatedBy,
      CreatedAt,
      FileName,
      Status,
      Attachment,
      Mimetype,
      _Items : redirected to composition child /EACM/C_A24_UPLOAD_ITEM
}
