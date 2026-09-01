@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'A24 Upload Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/I_A24LOGH
  as select from /eacm/a24logh

  composition [0..*] of /EACM/I_A24LOGI as _Items
  composition [0..*] of /EACM/I_A24LOGP as _Processes

{
  key requestid  as Requestid,
      created_by as CreatedBy,
      //            created_at as CreatedAt,
      tstmp_to_dats(
        created_at,
        abap_system_timezone( $session.client, 'NULL' ),
        $session.client,
        'NULL'
      )          as CreatedAt,
      tstmpl_to_utcl(
        created_at,
        'FAIL',
        'INITIAL'
      )          as CreatedAtDisplay,
      //    file_name as FileName,
      status     as Status,
//      case status
//        when 'RECEIVED'    then 'sap-icon://add-document'
//        when 'IN_PROGRESS' then 'sap-icon://in-progress'
//        when 'PARTIALLY'  then 'sap-icon://pending'
//        when 'COMPLETE' then 'sap-icon://complete'
//        else 'sap-icon://add-document'
//      end        as StatusIcon,
      case status
        when 'RECEIVED'    then 0 //Information blue
        when 'IN_PROGRESS' then 1 //rosso
        when 'PARTIALLY'  then 2 //Critical Arancione/Giallo
        when 'COMPLETE' then 3  // Positive verde
        else 0 // Neutral
      end        as StatusCriticality,
      //    attachment as Attachment,
      //    mimetype as Mimetype
      _Items,
      _Processes
}
