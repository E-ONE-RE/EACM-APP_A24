@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Help per domino /EACM/D_A24_STATUS'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_A24_STATUS_I
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: '/EACM/D_A24_STATUS')
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
where
       language  = $session.system_language
  and(
       value_low = 'UPLOADED'
    or value_low = 'IRRELEVANT'
    or value_low = 'ERROR'
    or value_low = 'WAIT'
  )
