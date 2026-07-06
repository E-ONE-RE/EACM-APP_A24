@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'A24 Upload Item'
@Metadata.allowExtensions: true
define view entity /EACM/C_A24LOGI
  as projection on /EACM/I_A24LOGI
{
    key Requestid,
    key Zlineno,
    Status,
    StatusCriticality,
    Message,
    Record,
    Vkorg,
    Vtweg,
    Zclpr,
    Vbeln,
    Posnr,
    Zcdaz,
    Zidag,
    /* Associations */
    _Header: redirected to parent /EACM/C_A24LOGH
}
