import java.sql.Types;
import java.util.List;
import java.util.Map;

import org.owasp.encoder.Encode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import mx.com.santander.clicktosell.commons.Click2Sell;
import mx.com.santander.clicktosell.configuration.SimpleJdbcCallFactory;
import mx.com.santander.clicktosell.dao.util.MapperDocumento;
import mx.com.santander.clicktosell.dao.util.MapperListadoDocumentos;
import mx.com.santander.clicktosell.exception.BusinessException;
import mx.com.santander.clicktosell.exception.ExceptionDefinition;
import mx.com.santander.clicktosell.model.DocumentoTO;
import mx.com.santander.clicktosell.model.MapeoDocumentoTO;
import mx.com.santander.clicktosell.model.ReqGuardaDocClienteTO;
import mx.com.santander.clicktosell.util.CommonsUtil;
import oracle.jdbc.OracleTypes;

@Repository
public class CertificadoMultianualDAO implements ICertificadoMultianualDAO {
	private static final Logger LOGGER = LoggerFactory.getLogger(CertificadoMultianualDAO.class);

	@Autowired
	private JdbcTemplate jdbcTemplate;
	
	@Autowired
	private SimpleJdbcCallFactory simpleJdbcCallFactory;

	@Override
	public List<DocumentoTO> getListaDocumentosGenerica(ReqGuardaDocClienteTO input, String token, boolean flgReintento)
			throws BusinessException {
		try {
			SimpleJdbcCall simpleJdbcCall = simpleJdbcCallFactory.create(jdbcTemplate).withCatalogName(Click2Sell.PKG_BASICAS)
					.withProcedureName(Click2Sell.PRC_LISTA_DOCS).withoutProcedureColumnMetaDataAccess()
					.returningResultSet(Click2Sell.OUT_CURSOR_DOCUMENTOS, new MapperListadoDocumentos())
					.declareParameters(new SqlParameter(Click2Sell.CURSOR_CODCLIENTE, Types.INTEGER),
							new SqlParameter(Click2Sell.CURSOR_CANALOFERTA, Types.INTEGER),
							new SqlParameter(Click2Sell.CURSOR_TIPO_PRODUCTO, Types.INTEGER),
							new SqlParameter(Click2Sell.CURSOR_PRODUCTO, Types.INTEGER),
							new SqlParameter(Click2Sell.CURSOR_SUB_PRODUCTO, Types.INTEGER),
							new SqlParameter(Click2Sell.CURSOR_MEDIO_ENTREGA, Types.INTEGER),
							new SqlParameter(Click2Sell.CURSOR_CVESESSION, Types.VARCHAR),
							new SqlParameter(Click2Sell.CURSOR_CVEEJECUTIVO, Types.VARCHAR),
							new SqlOutParameter(Click2Sell.CURSOR_CODERROR, Types.INTEGER),
							new SqlOutParameter(Click2Sell.CURSOR_MENSAJE, Types.VARCHAR),
							new SqlOutParameter(Click2Sell.OUT_CURSOR_DOCUMENTOS, OracleTypes.CURSOR));

			List<DocumentoTO> listDoc = null;

			// Si es cero colocar nulo
			SqlParameterSource in = new MapSqlParameterSource()
					.addValue(Click2Sell.CURSOR_CODCLIENTE, input.getPartyId())
					.addValue(Click2Sell.CURSOR_CANALOFERTA, input.getIdCanal())
					.addValue(Click2Sell.CURSOR_TIPO_PRODUCTO, Integer.parseInt("20"))
					.addValue(Click2Sell.CURSOR_PRODUCTO,  null)
					.addValue(Click2Sell.CURSOR_SUB_PRODUCTO,  null)
					.addValue(Click2Sell.CURSOR_MEDIO_ENTREGA,  null)
					.addValue(Click2Sell.CURSOR_CVESESSION, token)
					.addValue(Click2Sell.CURSOR_CVEEJECUTIVO, input.getCveEjecutivo()

					);
			
			
			LOGGER.info( Encode.forJava("p_cod_cliente ="+input.getPartyId()));
			LOGGER.info( Encode.forJava("p_cod_canal_oferta ="+input.getIdCanal()));
			LOGGER.info( Encode.forJava("p_cod_tipo_producto = 20"));
			LOGGER.info( Encode.forJava("p_cod_producto = null"));
			LOGGER.info( Encode.forJava("p_cod_subproducto = null"));
			LOGGER.info( Encode.forJava("p_cod_medio_entrega = null"));
			LOGGER.info( Encode.forJava("p_cve_sesion ="+token));
			LOGGER.info( Encode.forJava("p_cve_ejecutivo ="+input.getCveEjecutivo()));

			Map<String, Object> out = simpleJdbcCall.execute(in);
			int codError = (int) out.get(Click2Sell.CURSOR_CODERROR);
			String mensaje = (String) out.get(Click2Sell.CURSOR_MENSAJE);

			LOGGER.debug( Encode.forJava("codError::: {} mensaje::: {}"),  Encode.forJava(codError+""), Encode.forJava(mensaje));
			if (codError == 0) {
				listDoc = ((List<DocumentoTO>) out.get(Click2Sell.OUT_CURSOR_DOCUMENTOS));
				LOGGER.info( Encode.forJava("Numero de documentos: {}" + listDoc.size()));
			} else {
				LOGGER.error(Encode.forJava("Sin datos Mensaje: {} "), Encode.forJava(mensaje));
			}
			return listDoc;
		} catch (DataAccessException e) {
			LOGGER.error(Encode.forJava("Error en DAO"));
			throw new BusinessException(ExceptionDefinition.ORAERROR, " - Error al invocar getListaDocumentosGenerica",
					e, null);
		}

	}

	@Override
	public List<MapeoDocumentoTO> getMapeoDocumento(ReqGuardaDocClienteTO input, int codDocumento, String token,
			boolean flgReintento) throws BusinessException {
		try {
			SimpleJdbcCall simpleJdbcCall = simpleJdbcCallFactory.create(jdbcTemplate).withCatalogName(Click2Sell.PKG_BASICAS)
					.withProcedureName(Click2Sell.PRC_LLENA_DOCS).withoutProcedureColumnMetaDataAccess()
					.returningResultSet(Click2Sell.OUT_CURSOR_DATOS_CAMPOS_CUR, new MapperDocumento())
					.declareParameters(new SqlParameter(Click2Sell.CURSOR_SOLICITUD, Types.NUMERIC),
							new SqlParameter(Click2Sell.CURSOR_COD_DOCUMENTO, Types.NUMERIC),
							new SqlParameter(Click2Sell.CURSORTIPO_OFERTA, Types.NUMERIC),
							new SqlParameter(Click2Sell.CURSOR_CANAL, Types.NUMERIC),
							new SqlParameter(Click2Sell.CURSOR_CODCLIENTE, Types.NUMERIC),
							new SqlParameter(Click2Sell.CURSOR_CVESESSION, Types.VARCHAR),
							new SqlParameter(Click2Sell.CURSOR_CVEEJECUTIVO, Types.VARCHAR),
							new SqlOutParameter(Click2Sell.CURSOR_CODERROR, Types.INTEGER),
							new SqlOutParameter(Click2Sell.CURSOR_MENSAJE, Types.VARCHAR),
							new SqlOutParameter(Click2Sell.OUT_CURSOR_DATOS_CAMPOS_CUR, OracleTypes.CURSOR));

			List<MapeoDocumentoTO> listMap = null;

			SqlParameterSource in = new MapSqlParameterSource()
					.addValue(Click2Sell.CURSOR_SOLICITUD, Integer.parseInt(input.getCodSolicitud()))
					.addValue(Click2Sell.CURSOR_COD_DOCUMENTO, codDocumento)
					.addValue(Click2Sell.CURSORTIPO_OFERTA, input.getTipoProducto())
					.addValue(Click2Sell.CURSOR_CANAL, input.getIdCanal())
					.addValue(Click2Sell.CURSOR_CODCLIENTE, input.getPartyId())
					.addValue(Click2Sell.CURSOR_CVESESSION, token)
					.addValue(Click2Sell.CURSOR_CVEEJECUTIVO, input.getCveEjecutivo());
			
			
			
			LOGGER.info( Encode.forJava("p_cod_solicitud ="+input.getCodSolicitud()));
			LOGGER.info( Encode.forJava("p_cod_documento ="+codDocumento));
			LOGGER.info( Encode.forJava("p_cod_tipo_oferta ="+input.getTipoProducto()));
			LOGGER.info( Encode.forJava("p_cod_canal = "+input.getIdCanal()));
			LOGGER.info( Encode.forJava("p_cod_cliente = "+input.getPartyId()));
			LOGGER.info( Encode.forJava("p_cve_sesion ="+token));
			LOGGER.info( Encode.forJava("p_cve_ejecutivo ="+input.getCveEjecutivo()));

			Map<String, Object> out = simpleJdbcCall.execute(in);

			int codError = (int) out.get(Click2Sell.CURSOR_CODERROR);
			String message = (String) out.get(Click2Sell.CURSOR_MENSAJE);

			LOGGER.debug("codError::: {} mensaje::: {}", codError, message);
			if (1 == codError) {
				listMap = ((List<MapeoDocumentoTO>) out.get(Click2Sell.OUT_CURSOR_DATOS_CAMPOS_CUR));

				if (null != listMap && !(listMap.isEmpty())) {
					LOGGER.info(Encode.forJava(" HAY DATOS PARA ACROFIELD DOC {}"), Encode.forJava(codDocumento+""));
				} else {
					LOGGER.info(Encode.forJava(" NO HAY DATOS PARA ACROFIELD DOC {} "), Encode.forJava(codDocumento+""));
				}
			} else {
				LOGGER.error(Encode.forJava(" ERROR - NO HAY INFORMACIÓN DE MAPEO message: {}"), Encode.forJava(message));
			}
			return listMap;
		} catch (DataAccessException e) {
			LOGGER.error(Encode.forJava("Error en DAO"));
			throw new BusinessException(ExceptionDefinition.ORAERROR, " - Error al invocar getMapeoDocumento", e, null);
		}
	}

}
