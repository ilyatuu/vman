/**
 * 
 */
package iact.dev;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * @author iLya2
 *
 */
public class VA {

	private String sql,colname;
	private DbConnect db;
	private Connection cnn = null;
	private PreparedStatement pstm = null;
	private ResultSet rset = null;
	private ResultSetMetaData columns;
	
	private JSONObject json,jobj;
	private JSONArray jarr;
	
	private DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	private Date date = new Date();
	private String sqlDate = df.format(date);
	/**
	 * Assign CoD
	 */
	public boolean AssignCoD(JSONObject assignObj){
		try{
			sql  = " UPDATE _web_assignment SET coder1_coda=?,coder1_codb=?,coder1_codc=?,coder1_codd=?,coder1_comments=?";
			sql += " WHERE va_uri=? AND coder1_id=?;";
			
			db = new DbConnect();
			cnn = db.getConn();
			pstm = cnn.prepareStatement(sql);
			
			if(assignObj.getInt("coda")!=0){
				pstm.setInt(1, assignObj.getInt("coda"));
			}else{ 
				pstm.setNull(1, java.sql.Types.INTEGER);
			}
			
			if(assignObj.getInt("codb")!=0){ 
				pstm.setInt(2, assignObj.getInt("codb"));
			}else{ 
				pstm.setNull(2, java.sql.Types.INTEGER);}
			
			if(assignObj.getInt("codc")!=0){ 
				pstm.setInt(3, assignObj.getInt("codc"));
			}else{ 
				pstm.setNull(3, java.sql.Types.INTEGER);}
			
			if(assignObj.getInt("codd") != 0){ 
				pstm.setInt(4, assignObj.getInt("codd"));
			}else{ 
				pstm.setNull(4, java.sql.Types.INTEGER);}
			
			if(assignObj.has("notes")){ 
				pstm.setString(5, assignObj.getString("notes"));
			}else{ 
				pstm.setNull(5, java.sql.Types.VARCHAR);}
			
			pstm.setString(6, assignObj.getString("vaid"));
			pstm.setInt(7, assignObj.getInt("userid"));
			
			System.out.println(pstm.toString());
			pstm.executeUpdate();
			
			//Check Coder 2
			sql  = " UPDATE _web_assignment SET coder2_coda=?,coder2_codb=?,coder2_codc=?,coder2_codd=?,coder2_comments=?";
			sql += " WHERE va_uri=? AND coder2_id=?;";
			
			pstm = cnn.prepareStatement(sql);
			if(assignObj.getInt("coda")!=0){
				pstm.setInt(1, assignObj.getInt("coda"));
			}else{ 
				pstm.setNull(1, java.sql.Types.INTEGER);
			}
			
			if(assignObj.getInt("codb")!=0){ 
				pstm.setInt(2, assignObj.getInt("codb"));
			}else{ 
				pstm.setNull(2, java.sql.Types.INTEGER);}
			
			if(assignObj.getInt("codc")!=0){ 
				pstm.setInt(3, assignObj.getInt("codc"));
			}else{ 
				pstm.setNull(3, java.sql.Types.INTEGER);}
			
			if(assignObj.getInt("codd") != 0){ 
				pstm.setInt(4, assignObj.getInt("codd"));
			}else{ 
				pstm.setNull(4, java.sql.Types.INTEGER);}
			
			if(assignObj.has("notes")){ 
				pstm.setString(5, assignObj.getString("notes"));
			}else{ 
				pstm.setNull(5, java.sql.Types.VARCHAR);}
			
			pstm.setString(6, assignObj.getString("vaid"));
			pstm.setInt(7, assignObj.getInt("userid"));
			
			System.out.println(pstm.toString());
			pstm.executeUpdate();
			
			return true;
		}catch(SQLException e){
			e.printStackTrace();
			return false;
		}catch(Exception e){
			e.printStackTrace();
			return false;
		}finally{
			try{
		         if(pstm!=null)
		            pstm.close();
		      }catch(SQLException se){
		      }// do nothing
		      try{
		         if(cnn!=null)
		            cnn.close();
		      }catch(SQLException se){
		         se.printStackTrace();
		      }//end finally try
		}
	}
	/**
	 * Get Discordant VA
	 */
	public JSONObject getDiscordantVA(int coderId){
		try{
			sql="SELECT * FROM view_individual_va WHERE (c1ucd != c2ucd) and (c1id=? OR c2id=?);";
			db = new DbConnect();
			cnn = db.getConn();
			pstm = cnn.prepareStatement(sql);
			pstm.setInt(1, coderId);
			pstm.setInt(2, coderId);
			rset = pstm.executeQuery();
			columns = rset.getMetaData();
			jarr = new JSONArray();
			while(rset.next()){
				json = new JSONObject();
				for(int i=1;i<=columns.getColumnCount();i++){
					json.put(columns.getColumnName(i), rset.getObject(i));
				}
				jarr.put(json);
			}
			jobj = new JSONObject();
			jobj.put("total", jarr.length());
			jobj.put("rows", jarr);
			return jobj;
		}catch(SQLException e){
			e.printStackTrace();
			return null;
		}catch(Exception e){
			e.printStackTrace();
			return null;
		}finally{
			try{
		         if(pstm!=null)
		            pstm.close();
		      }catch(SQLException se){
		    	  se.printStackTrace();
		      }
		      try{
		         if(cnn!=null)
		            cnn.close();
		      }catch(SQLException se){
		         se.printStackTrace();
		      }//end finally try
		}
	}
	public JSONObject getVARec(String vaid){
		try{
			
			sql="SELECT * FROM view_va WHERE _URI like ?";
			db = new DbConnect();
			cnn = db.getConn();
			pstm = cnn.prepareStatement(sql);
			pstm.setString(1, vaid);
			rset = pstm.executeQuery();
			columns = rset.getMetaData();
			if(rset.next()){
				json = new JSONObject();
				//Forward way use (int i=1;i<=columns.getColumnCount();i++)
				//Backward way use (int i=columns.getColumnCount();i>0;i--)
				for(int i=1;i<=columns.getColumnCount();i++){
					colname = columns.getColumnName(i);
					if(colname.indexOf("_ID") > 0){
						colname = colname.substring(colname.indexOf("_ID")+1, colname.length());
					}					
					json.put(colname, rset.getObject(i));
				}
			}
			return json;
		}catch(SQLException e){
			e.printStackTrace();
			return null;
		}catch(Exception e){
			e.printStackTrace();
			return null;
		}finally{
			try{
		         if(pstm!=null)
		            pstm.close();
		      }catch(SQLException se){
		      }// do nothing
		      try{
		         if(cnn!=null)
		            cnn.close();
		      }catch(SQLException se){
		         se.printStackTrace();
		      }//end finally try
		}
	}
	/**
	 * Get VA Document
	 */
	public JSONObject getVARec(String vaid, String tbl){
		try{
			sql="SELECT * FROM "+tbl+" WHERE \"_URI\" like ?";
			db = new DbConnect();
			cnn = db.getConn();
			pstm = cnn.prepareStatement(sql);
			pstm.setString(1, vaid);
			rset = pstm.executeQuery();
			columns = rset.getMetaData();
			if(rset.next()){
				json = new JSONObject();
				//Forward way use (int i=1;i<=columns.getColumnCount();i++)
				//Backward way use (int i=columns.getColumnCount();i>0;i--)
				for(int i=1;i<=columns.getColumnCount();i++){
					colname = columns.getColumnName(i);
					if(colname.indexOf("_ID") > 0){
						colname = colname.substring(colname.indexOf("_ID")+1, colname.length());
					}					
					json.put(colname, rset.getObject(i));
				}
			}
			return json;
		}catch(SQLException e){
			e.printStackTrace();
			return null;
		}catch(Exception e){
			e.printStackTrace();
			return null;
		}finally{
			try{
		         if(pstm!=null)
		            pstm.close();
		      }catch(SQLException se){
		      }// do nothing
		      try{
		         if(cnn!=null)
		            cnn.close();
		      }catch(SQLException se){
		         se.printStackTrace();
		      }//end finally try
		}
		
	}
	/*
	 * Assign VA
	 * */
	public boolean AssignVA(JSONObject vaObj){
		try{
			if(vaObj.getInt("coderType")==1){
				//Coder 1
				if(vaObj.getString("assignType").equalsIgnoreCase("assign")){
					sql  = "INSERT INTO _web_assignment(coder1_id,coder1_assigned_date,va_uri) VALUES(?,?,?);";
				}else{
					//Update
					sql  = "UPDATE _web_assignment SET coder1_id=?,coder1_assigned_date=? WHERE va_uri=?;";
				}
			}else{
				//Coder 2
				if(vaObj.getString("assignType").equalsIgnoreCase("assign")){
					sql  = "INSERT INTO _web_assignment(coder2_id,coder2_assigned_date,va_uri) VALUES(?,?,?);";
				}else{
					sql  = "UPDATE _web_assignment SET coder2_id=?,coder2_assigned_date=? WHERE va_uri=?;";
				}
				
			}
			db = new DbConnect();
			cnn = db.getConn();
			pstm = cnn.prepareStatement(sql);
			cnn.setAutoCommit(false); //if you want to manually commit
			JSONArray jarr = new JSONArray();
			jarr = vaObj.getJSONArray("vaIds");
			for(int i=0;i<jarr.length();i++){
				pstm.setInt(1, vaObj.getInt("coderId"));
				pstm.setTimestamp(2, Timestamp.valueOf(sqlDate));
				pstm.setString(3, jarr.getString(i));
				pstm.addBatch();
			}			
			pstm.executeBatch();
			cnn.commit();
			return true;
		}catch(SQLException e){
			e.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			try{
		         if(pstm!=null)
		            pstm.close();
		      }catch(SQLException se){
		      }// do nothing
		      try{
		         if(cnn!=null)
		            cnn.close();
		      }catch(SQLException se){
		         se.printStackTrace();
		      }//end finally try
		}
		return false;
	}
	/**
	 * Get ICD10 Codes
	 */
	public JSONArray getICD10List(){
		try{
			sql  = "SELECT id,icdname,icdcode,concat(icdcode,' | ',icdname) as icdlabel ";
			sql += "FROM _web_icd10;";
			db = new DbConnect();
			cnn = db.getConn();
			pstm = cnn.prepareStatement(sql);
			rset = pstm.executeQuery();
			jarr = new JSONArray();
			while(rset.next()){
				json = new JSONObject();
				json.put("id", rset.getInt(1));
				json.put("icdname",  rset.getString(2));
				json.put("icdcode",  rset.getString(3));
				json.put("icdlabel", rset.getString(4));
				
				jarr.put(json);
			}
			return jarr;
		}catch(SQLException e){
			e.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			try{
		         if(pstm!=null)
		            pstm.close();
		      }catch(SQLException se){
		      }// do nothing
		      try{
		         if(cnn!=null)
		            cnn.close();
		      }catch(SQLException se){
		         se.printStackTrace();
		      }//end finally try
		}
		return null;
	}
}
