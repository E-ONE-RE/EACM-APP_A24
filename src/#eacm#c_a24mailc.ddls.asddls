@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: '/EACM/A24MAILC'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_A24MAILC
  provider contract TRANSACTIONAL_QUERY
  as projection on /EACM/R_A24MAILC
  association [1..1] to /EACM/R_A24MAILC as _BaseEntity on $projection.CONFIGID = _BaseEntity.CONFIGID
{
  key ConfigID,
  Active,
  SendMode,
  Recipient,
  Sender,
  SubjectPrefix,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
