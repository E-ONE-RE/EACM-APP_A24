@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'A24 mail send mode value help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity /EACM/I_A24_SEND_MODE
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T(
    p_domain_name: '/EACM/D_A24_SEND_MODE'
  )
{
      @UI.hidden: true
  key domain_name,

      @UI.hidden: true
  key value_position,

      @Semantics.language: true
      @UI.hidden: true
  key language,

      value_low,

      @Semantics.text: true
      text
}
where language = $session.system_language
