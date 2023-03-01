*----------------------------------------------------------------------*
* TEMPLATE VITRO ABAP FACTORY (VERSION EN ESPAÑOL)               *
*----------------------------------------------------------------------*
*..............                                                        *
*.........______                                                       *
*____..../             ._.                                             *
*__  \../   ____ ._.  _! !__   ____    __                              *
*...\ \/   /.... | | !_   __! |  __!  /  \                             *
*....\    /..... | |   | |    | /    | !! |                            *
*.....\  /...... | |   | |_   | |    | !! |                            *
* .....\/......  !_!   !___!  !_!     \__/                             *
*----------------------------------------------------------------------*
*                    VITRO ABAP  Factory                               *
*----------------------------------------------------------------------*
* Programa             : ZINMEXMD1_MATE_ARIBA                          *
* Descripción          : Material’s URLs Design  - Ariba               *
* Programa Std base    : Nombre del programa std aplica solo en copias *
* Consultor Funcional  : Nombre del consultor funcional.               *
* Consultor Tecnico    : Johan Rodríguez / Ángel Rodríguez.            *
* Desarrollador        : Johan Rodríguez /Ángel Rodríguez.             *
* Fecha Creación       : 17.02.2023                                    *
* Número de Req.       : Número de Referencia                          *
* SOLO APLICA EN COPIAS DE STD, borre las lineas sino son necesarias   *
* Componentes relacionados                                             *
* Detalle los componentes std copiados a Z relacionados                *
*----------------------------------------------------------------------*
report  zinmexmd1_mate_ariba.
*----------------------------------------------------------------------*
* Declaración de Includes.                                             *
*----------------------------------------------------------------------*
include zinmexmd1_mate_ariba_top.
include zinmexmd1_mate_ariba_form.
*----------------------------------------------------------------------*
*                START-OF-SELECTION                                    *
*----------------------------------------------------------------------*
start-of-selection.

  clear : lv_xstring, lv_string, lv_node_name.


  "Direct Connectivity Parameters
  select single realm
  from arbcig_authparam
  into lv_realm
  where solution eq lc_as.
  if sy-subrc eq 0.

    translate lv_realm to upper case.

    select name
           fieldname
           low
    from arbcig_tvarv
    into table i_tvarv
    where fieldname eq lv_realm
    and name in ('SRC_URL_OR_APIKEY', 'SRC_URL_OR_CLIENTID',
                   'SRC_URL_OR_SECRET', 'SRC_URL_OR_TEMPLATE',
                   'SRC_URL_EM_APIKEY', 'SRC_URL_EM_CLIENTID',
                   'SRC_URL_EM_SECRET', 'SRC_URL_EM_USER',
                   'SRC_URL_EM_USER_PA', 'SRC_URL_LAST_EXECUTION').
    if sy-subrc eq 0.

      "Clasificar datos del campo low tabla arbcig_tvarv
      loop at i_tvarv into lw_tvarv.
        case lw_tvarv-name.
          when 'SRC_URL_EM_APIKEY'.
            em_apikey = lw_tvarv-low.
          when 'SRC_URL_EM_CLIENTID'.
            em_clientid = lw_tvarv-low.
          when 'SRC_URL_EM_SECRET'.
            em_secret  = lw_tvarv-low.
          when 'SRC_URL_EM_USER'.
            em_user = lw_tvarv-low.
          when 'SRC_URL_EM_USER_PA'.
            em_user_pa = lw_tvarv-low.
          when 'SRC_URL_LAST_EXECUTION'.
            last_execution = lw_tvarv-low.
          when 'SRC_URL_OR_APIKEY'.
            or_apikey = lw_tvarv-low.
          when 'SRC_URL_OR_CLIENTID'.
            or_clientid = lw_tvarv-low.
          when 'SRC_URL_OR_SECRET'.
            or_secret = lw_tvarv-low.
          when 'SRC_URL_OR_TEMPLATE'.
            or_template = lw_tvarv-low.
        endcase.
      endloop.
*----------------------------------------------------------*
*        Token Operation Reporting                         *
*----------------------------------------------------------*
      perform f_token_operation_reporting.
*----------------------------------------------------------*
*           Token Event Management                         *
*----------------------------------------------------------*
      perform f_token_event_management.
*----------------------------------------------------------*
*           Obtener Proyectos de Sourcing                  *
*----------------------------------------------------------*
      perform f_obtener_proyectos_sourcing.
*----------------------------------------------------------*
*           Obtener Sourcing Event                         *
*----------------------------------------------------------*
      perform f_sourcing_event.
      message text-002 type 'S'.

    else.
      message text-001 type 'E'.
    endif.
  endif.
