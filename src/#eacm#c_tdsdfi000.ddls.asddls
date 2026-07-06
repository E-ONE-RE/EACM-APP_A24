@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: '/EACM/TDSDFI000'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_TDSDFI000
  provider contract TRANSACTIONAL_QUERY
  as projection on /EACM/R_TDSDFI
  association [1..1] to /EACM/R_TDSDFI as _BaseEntity on $projection.VKORG = _BaseEntity.VKORG and $projection.FKART = _BaseEntity.FKART
{
  key Vkorg,
  key Fkart,
  Blart,
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
