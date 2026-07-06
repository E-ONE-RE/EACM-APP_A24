@EndUserText.label: 'Items Request/Response'
define custom entity /EACM/A24Items
  //composition of target_data_source_name as _association_name
{
  key RequestId : sysuuid_x16;
      //  key vkorg          : vkorg;
      //  key vtweg          : vtweg;
      //  key nfat           : vbeln;
      //  key posnr          : posnr;
      //      spart          : spart;
      //      werks          : werks_d;
      //      lgort          : lgort_d;
      //      bukrs          : bukrs;
      //      dtfat          : abap.datn;
      //      fkart          : fkart;
      //      nord           : vbeln;
      //      dord           : fkdat;
      //      auart          : auart;
      //      ndnt           : vbeln;
      //      ddnt           : abap.datn;
      //      nship          : /eacm/tknum;
      //      @EndUserText.label : 'Data shipmen'
      //      dship          : abap.dats;
      //      @EndUserText.label : 'Num. XAB'
      //      nxab           : abap.char(10);
      //      @EndUserText.label : 'Data XAB'
      //      dxab           : abap.dats;
      //      kndnr          : kunnr;
      //      vrtnr          : /eacm/zcdaz;
      //      @EndUserText.label : 'Canale di vendita'
      //      kdgrp          : abap.char(3);
      //      @EndUserText.label : 'Segmento commeciale'
      //      kondd          : abap.char(3);
      //      @EndUserText.label : 'Provincia'
      //      brsch          : abap.char(4);
      //      regio          : regio;
      //      @EndUserText.label : 'Codice trasporto'
      //      liko1          : abap.char(1);
      //      @EndUserText.label : 'Codice spedizione'
      //      liko2          : abap.char(1);
      //      liko3          : abap.char(1);
      //      liko4          : abap.char(1);
      //      @EndUserText.label : 'Categoria Bovis'
      //      zcat           : abap.char(3);
      //      @EndUserText.label : 'Ubicazione logistica'
      //      zubil          : abap.char(1);
      //      @EndUserText.label : 'Ubicazione fisica'
      //      zubif          : abap.char(1);
      //      bsark          : /eacm/bsark;
      //      zterm          : dzterm;
      //      knrze          : knrze;
      //      waerk          : waerk;
      //      waerl          : waerk;
      //      kurks          : abap.char(9);
      //      kurun          : abap.char(9);
      //      vkgrp          : vkgrp;
      //      @EndUserText.label : 'Commessa'
      //      awbnr          : abap.char(15);
      //      mtart          : mtart;
      //      @EndUserText.label : 'Flag fat/ord/del'
      //      fftor          : abap.char(1);
      //      hpbuz          : posnr_va;
      //      upbuz          : posnr;
      //      vsdat          : abap.char(8);
      //      pstyp          : pstyp;
      //      @EndUserText.label : 'Flag per ordinare'
      //      flag           : abap.char(1);
      //      @EndUserText.label : 'Falg T9404'
      //      zfag           : abap.char(1);
      //      @EndUserText.label : 'Flag procedura'
      //      zflg           : abap.char(10);
      //      artnr          : matnr;
      //      @EndUserText.label : 'Classe di sconto'
      //      clsco          : abap.char(3);
      //      @EndUserText.label : 'Codice statistico'
      //      prodh          : abap.char(6);
      //      prodh_ipos     : abap.char(18);
      //      mwskz          : mwskz;
      //      arktx          : arktx;
      //      @EndUserText.label : 'Quantità'
      //      fkimg          : abap.char(11);
      //      @EndUserText.label : 'Prezzo netto'
      //      netpr          : abap.char(9);
      //      @EndUserText.label : 'Sconto'
      //      sconto         : abap.char(7);
      //      @EndUserText.label : 'Costo'
      //      vrwrt          : abap.char(11);
      //      @EndUserText.label : 'Segno costo'
      //      vrwrt_segno    : abap.char(1);
      //      @EndUserText.label : 'Prezzo lordo'
      //      netw2          : abap.numc(11);
      //      @EndUserText.label : 'Segno prezzo lordo'
      //      netw2_segno    : abap.char(1);
      //      @EndUserText.label : 'Margine'
      //      margi          : abap.numc(7);
      //      @EndUserText.label : 'Segno margine'
      //      margi_segno    : abap.char(1);
      //      @EndUserText.label : 'Prezzo listino'
      //      brtpr          : abap.numc(9);
      //      @EndUserText.label : 'Quantità blister'
      //      blister        : abap.numc(11);
      //      @EndUserText.label : 'Quantità ordinata'
      //      menge          : abap.numc(11);
      //      @EndUserText.label : 'Flag NF'
      //      nfakt_fl       : abap.char(1);
      //      @EndUserText.label : 'Costo NF'
      //      vrwrt_nf       : abap.numc(11);
      //      @EndUserText.label : 'Segno NF'
      //      vrwrt_nf_segno : abap.char(1);
      //      fill31         : abap.char(1);
      //      fill32         : abap.numc(12);
      //      vrtnr_2        : abap.char(10);
      //      artwa          : abap.char(18);
      //      @EndUserText.label : 'Inizio n. fattura'
      //      iftr3          : abap.char(2);
      //      fil30          : abap.char(8);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsl1          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk11          : abap.char(1);
      //      rbk91          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbe1          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbe1_sign     : abap.char(1);
      //      rbwe1          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbaw1          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsl2          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk12          : abap.char(1);
      //      rbk92          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbe2          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbe2_sign     : abap.char(1);
      //      rbwe2          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbaw2          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsl3          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk13          : abap.char(1);
      //      rbk93          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbe3          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbe3_sign     : abap.char(1);
      //      rbwe3          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbaw3          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsl4          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk14          : abap.char(1);
      //      rbk94          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbe4          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbe4_sign     : abap.char(1);
      //      rbwe4          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbaw4          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsl5          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk15          : abap.char(1);
      //      rbk95          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbe5          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbe5_sign     : abap.char(1);
      //      rbwe5          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbaw5          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsl6          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk16          : abap.char(1);
      //      rbk96          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbe6          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbe6_sign     : abap.char(1);
      //      rbwe6          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbaw6          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsl7          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk17          : abap.char(1);
      //      rbk97          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbe7          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbe7_sign     : abap.char(1);
      //      rbwe7          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbaw7          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsl8          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk18          : abap.char(1);
      //      rbk98          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbe8          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbe8_sign     : abap.char(1);
      //      rbwe8          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbaw8          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsl9          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk19          : abap.char(1);
      //      rbk99          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbe9          : abap.char(9);
      //      @EndUserText.label : 'Segno'
      //      rbbe9_sign     : abap.char(1);
      //      rbwe9          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbaw9          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbslf          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk1f          : abap.char(1);
      //      rbk9f          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbef          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbef_sign     : abap.char(1);
      //      rbwef          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbawf          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbslg          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk1g          : abap.char(1);
      //      rbk9g          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbeg          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbeg_sign     : abap.char(1);
      //      rbweg          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbawg          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbslh          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk1h          : abap.char(1);
      //      rbk9h          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbeh          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbeh_sign     : abap.char(1);
      //      rbweh          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbawh          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsli          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk1i          : abap.char(1);
      //      rbk9i          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbei          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbei_sign     : abap.char(1);
      //      rbwei          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbawi          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbslj          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk1j          : abap.char(1);
      //      rbk9j          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbej          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbej_sign     : abap.char(1);
      //      rbwej          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbawj          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbslk          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk1k          : abap.char(1);
      //      rbk9k          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbek          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbek_sign     : abap.char(1);
      //      rbwek          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbawk          : abap.numc(11);
      //      @EndUserText.label : 'Gruppo condizioni'
      //      rbsll          : abap.char(4);
      //      @EndUserText.label : 'Tipo di calcolo'
      //      rbk1l          : abap.char(1);
      //      rbk9l          : abap.char(1);
      //      @EndUserText.label : 'Importo sconto'
      //      rbbel          : abap.numc(9);
      //      @EndUserText.label : 'Segno'
      //      rbbel_sign     : abap.char(1);
      //      rbwel          : abap.numc(9);
      //      @EndUserText.label : 'Valore base'
      //      rbawl          : abap.numc(11);
      //      flag_v2        : abap.char(1);
      //      ktgrm          : abap.char(4);
      //      kdlif          : abap.char(10);
      //      kdrch          : abap.char(10);
      //      vsart          : abap.char(2);
      //      lpstl          : abap.char(10);
      //      zrmt_1         : abap.char(1);
      //      zrmt_2         : abap.char(18);
      //      name1          : abap.char(40);
      //      augru          : abap.char(3);
      //      fill2          : abap.char(18);
      //      //      Response : composition [1..*] of /EACM/A24MessageResponse;
  key Record    : abap.sstring( 1201 );
      Status    : abap.char( 2 );
      Message   : abap.char( 255 );
      Request   : association to parent /EACM/A24Request on Request.RequestId = $projection.RequestId;
}
