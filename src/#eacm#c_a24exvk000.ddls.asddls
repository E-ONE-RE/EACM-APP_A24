@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: '/EACM/A24EXVK000'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_A24EXVK000
  provider contract TRANSACTIONAL_QUERY
  as projection on /EACM/R_A24EXVK
  association [1..1] to /EACM/R_A24EXVK as _BaseEntity on $projection.VKORG = _BaseEntity.VKORG
{
  key Vkorg,
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
