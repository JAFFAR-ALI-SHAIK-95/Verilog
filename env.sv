class env extends uvm_env;
  `uvm_component_utils(env)
  
  v_sequencer v_seqr;
  src_agt_top s_agt_top;
  dst_agt_top d_agt_top;
  scoreboard sb;
  cov_col covh;
  env_cdb e_cdb;
  
  function new(string name="env",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    uvm_config_db #(env_cdb) ::get(this,"","env_cdb",e_cdb);
    
    if(e_cdb.has_v_seqr)
	begin
      v_seqr=v_sequencer::type_id::create("v_seqr",this);
    uvm_config_db #(env_cdb) ::set(this,"*v_seqr*","env_cdb",e_cdb);
    	end
    if(e_cdb.has_sagt)
	begin
      s_agt_top=src_agt_top::type_id::create("s_agt_top",this);
	uvm_config_db #(env_cdb) ::set(this,"*s_agt_top","env_cdb",e_cdb);
    foreach(e_cdb.s_cdb[i])
      uvm_config_db #(sagt_cdb) ::set(this,$sformatf("s_agt_top.s_agt[%0d]*",i),"sagt_cdb",e_cdb.s_cdb[i]);
      end
    if(e_cdb.has_dagt)
    begin
      d_agt_top=dst_agt_top::type_id::create("d_agt_top",this);
 	uvm_config_db #(env_cdb) ::set(this,"*d_agt_top","env_cdb",e_cdb);
    foreach(e_cdb.d_cdb[i])
      uvm_config_db #(dagt_cdb) ::set(this,$sformatf("d_agt_top.d_agt[%0d]*",i),"dagt_cdb",e_cdb.d_cdb[i]);
    end
    if(e_cdb.has_sb)
	begin
      sb=scoreboard::type_id::create("sb",this);
    uvm_config_db #(env_cdb) ::set(this,"*sb*","env_cdb",e_cdb);
    	end
    if(e_cdb.has_cov_col)
	begin
      covh=cov_col::type_id::create("covh",this);
    uvm_config_db #(env_cdb) ::set(this,"covh*","env_cdb",e_cdb);
	end
  endfunction
  
  function void connect_phase(uvm_phase phase);
    if(e_cdb.has_sagt)
    foreach(v_seqr.s_seqr[i])
	begin
      		v_seqr.s_seqr[i]=s_agt_top.s_agt[i].s_seqr;
		//$display("s_seqr[%0d]=%0d",i,v_seqr.s_seqr[i]);
	end
    if(e_cdb.no_of_dagt)
    foreach(v_seqr.d_seqr[i])
      v_seqr.d_seqr[i]=d_agt_top.d_agt[i].d_seqr;
    
    if(e_cdb.has_sb)
      begin
        foreach(sb.s_fifoh[i])
          s_agt_top.s_agt[i].s_mon.mon_port.connect(sb.s_fifoh[i].analysis_export);
        foreach(sb.d_fifoh[i])
          d_agt_top.d_agt[i].d_mon.mon_port.connect(sb.d_fifoh[i].analysis_export);
      end
    if(e_cdb.has_cov_col)
      sb.cov_port.connect(covh.analysis_export);
   endfunction
endclass
           
  
