@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: '/EACM/IT_913000'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_IT_913000
  provider contract TRANSACTIONAL_QUERY
  as projection on /EACM/R_IT_913
  association [1..1] to /EACM/R_IT_913 as _BaseEntity on $projection.BUKRS = _BaseEntity.BUKRS and $projection.BLART = _BaseEntity.BLART
{
  key Bukrs,
  key Blart,
  Zf07,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreatedAt,
  @Semantics: {
    User.Lastchangedby: true
  }
  ChangedBy,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  ChangedAt,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
