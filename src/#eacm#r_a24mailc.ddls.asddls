@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: '/EACM/A24MAILC'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity /EACM/R_A24MAILC
  as select from /EACM/A24MAILC
{
  key config_id as ConfigID,
  active as Active,
  send_mode as SendMode,
  recipient as Recipient,
  sender as Sender,
  subject_prefix as SubjectPrefix,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
