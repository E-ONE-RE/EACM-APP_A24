@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interfaccia per upload A24'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/I_A24_UPLOAD
  as select from /eacm/a24logh
  composition [1..*] of /EACM/I_A24_UPLOAD_ITEM as _Items
{
  key requestid  as Requestid,
      created_by as CreatedBy,
      created_at as CreatedAt,
      file_name  as FileName,
      status     as Status,
      attachment as Attachment,
      mimetype   as Mimetype,
      _Items
}
