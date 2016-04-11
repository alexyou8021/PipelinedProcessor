`define F 0
`define D 1
`define E 2
`define M 3
`define WB 4

module main();

    initial begin
        $dumpfile("ppc.vcd");
        $dumpvars(0,main);
    end

    wire clk;
    wire halt;
    clock clock0(halt,clk);

	always @(posedge clk) begin
		//$display (pcWB);
		//$display ("%d:%d",opWB,nopWB);
		//$display (memWriteAddr);
		//$display (branchTarget);
		//$display ("%d : %h", targetWriteAddr0WB, targetVal1);
		if(isBranchingWB&&!nopWB) begin
			pc <= branchTarget;
			//nopF <= 1;
			nopD <= 1;
			nopE <= 1;
			nopWB <= 1;
		end else if(isSTDWB) begin
			if(memWriteEn&&memWriteAddr==pcWB[0:60]) begin
				pc <= pcE;
				nopD <= 1;
				nopE <= 1;
				nopWB <= 1;
			end
			else if(memWriteAddr==pcD[0:60]) begin
				pc <= pcE;
				nopD <= 1;
				nopE <= 1;
				nopWB <= 1;
			end
			else if(memWriteAddr==pc[0:60]) begin
				pc <= pcE;
				nopD <= 1;
				nopE <= 1;
				nopWB <= 1;
			end
			else begin 
				pc <= nextPC;
				pcD <= pc;
				pcE <= pcD;
				pcWB <= pcE;
				nopF <= 0;
				nopD <= nopF;
				nopE <= nopD;
				nopWB <= nopE;
			end
		end else begin
			pc <= nextPC;
			pcD <= pc;
			pcE <= pcD;
			pcWB <= pcE;
			nopF <= 0;
			nopD <= nopF;
			nopE <= nopD;
			nopWB <= nopE;
		end

		instrWB <=instrE;
		instrE <= instr;
		ravWB <= rav;
		rbvWB <= rbv;
		rsvWB <= rsv;
		reg0WB <= reg0;
		reg3WB <= reg3;
		Ago1WriteEn0 <= regWriteEn0;
		Ago1WriteAddr0 <= regWriteAddr0;
		Ago1WriteData0 <= regWriteData0;
		Ago1WriteEn1 <= regWriteEn1;
		Ago1WriteAddr1 <= regWriteAddr1;
		Ago1WriteData1 <= regWriteData1;
		Ago1memWriteEn <= memWriteEn;
		Ago1memWriteAddr <= memWriteAddr;
		Ago1memWriteData <= memWriteData;
		run1 <= run1+1;
		if(!nopWB) begin
			if(isBWB|isBCWB|isBCLRWB) begin
				if(isBCWB|isBCLRWB) begin
					if(!boWB[2]) begin
						ctr <= ctr - 1;
					end
				end	
				if(isLK) begin
					lr <= {pcWB[0:61],2'b00}+4 ;
				end
			end
			if(isMTSPRWB) begin
				if(sprWB==8) begin 
					lr <= nextLR;
				end
				if(sprWB==1) begin 
					xer <= nextXER;
				end
				if(sprWB==9) begin 
					ctr <= nextCTR;
				end
			end
			if(isSCWB&&(instrWB[30]==1)&&(lev==0|lev==1)) begin
				if(reg0WB==0) begin
					$display ("%c",reg3charWB);
				end
				else if(reg0WB==1) begin
					//$finish;
				end
				else if(reg0WB==2) begin
					$display ("%h",reg3WB);
				end
			end
			if(isRC&&(isAddWB|isOrWB)) begin
				crWB[0] <= targetVal1[0]==1;
				crWB[1] <= targetVal1[0]==0 && targetVal1!=0;
				crWB[2] <= targetVal1==0;
				crWB[3] <= (isOE) ? (ov|xer[32]) : xer[32];
			end
			if(isMTCRFWB&&instrWB[11]==0) begin
				if(fxm[0]==1) begin
					crWB[0] <= rsvWB[32];
					crWB[1] <= rsvWB[33];
					crWB[2] <= rsvWB[34];
					crWB[3] <= rsvWB[35];
				end
			end
			if(isOE&&(isAddWB|isOrWB)) begin
					xer[32] <= ov|xer;
					xer[33] <= ov;
			end
		end
	end	
//							PC
	reg [0:63] pc = 0;
	reg [0:63] pcD = 0;
	reg [0:63] pcE = 0;
	reg [0:63] pcWB = 0;
	wire [0:63] nextPC = pc+4;

//						CR
	reg [31:0] crWB = 0;
	reg [0:63] ctr = 0;
	reg [0:63] lr = 0;
	reg [0:63] xer = 0;
//						NOP
	reg nopF = 0;
	reg nopD = 0;
	reg nopE = 0;
	reg nopWB = 0;
	
    /********************/
    /* Memory interface */
    /********************/

    wire memReadEn0;
    wire [0:60]memReadAddr0;
    wire [0:63]memReadData0;
    wire memReadEn1;
    wire [0:60]memReadAddr1;
    wire [0:63]memReadData1;
    wire memWriteEn;
    wire [0:60]memWriteAddr;
    wire [0:63]memWriteData;

    mem mem0(clk,
        memReadEn0,memReadAddr0,memReadData0,
        memReadEn1,memReadAddr1,memReadData1,
	memWriteEn,memWriteAddr,memWriteData);

    /********/
    /* regs */
    /********/

    wire regReadEn0;
    wire [0:4]regReadAddr0;
    wire [0:63]regReadData0;

    wire regReadEn1;
    wire [0:4]regReadAddr1;
    wire [0:63]regReadData1;


    wire regWriteEn0;
    wire [0:4]regWriteAddr0;
    wire [0:63]regWriteData0;

    wire regWriteEn1;
    wire [0:4]regWriteAddr1;
    wire [0:63]regWriteData1;

    regs gprs(clk,
       /* Read port #0 */
       regReadEn0,
       regReadAddr0, 
       regReadData0,

       /* Read port #1 */
       regReadEn1,
       regReadAddr1, 
       regReadData1,

       /* Write port #0 */
       regWriteEn0,
       regWriteAddr0, 
       regWriteData0,

       /* Write port #1 */
       regWriteEn1,
       regWriteAddr1, 
       regWriteData1
    );
//						FETCH	
        assign memReadEn0 = 1;
    	assign memReadAddr0 = pc[0:60];
//						DECODE
	wire [0:31] instr =  pcD[61] ? memReadData0[32:63] : memReadData0[0:31];
	wire [0:5] op = instr [0:5];
	wire [0:8] xop9 = instr [22:30];
	wire [0:9] xop10 = instr [21:30];
	wire [0:1] xop2 = instr [30:31];

	wire [0:4] rt = instr [6:10];
	wire [0:4] ra = instr [11:15];
	wire [0:4] rb = instr [16:20];
	wire oe = instr[21];
	wire rc = instr[31];
	wire [0:4] rs = instr [6:10];
	wire [0:63] si = { {48{instr [16]}} , instr [16:31]};
	wire [0:63] li = { {38{instr[6]}}, instr [6:29], 2'b00};
	wire aa = instr [30];
	wire lk = instr [31];
	wire [0:4] bo = instr [6:10];
	wire [0:4] bi = instr [11:15];
	wire [0:63] bd = { { {48{instr [16]}}, instr [16:29]}, 2'b00};
	wire bh = instr[19];
	wire [0:63] ds = { {48{instr [16]}} , instr [16:29], 2'b00};

	wire isAdd = (op == 31) & (xop9 == 266);
	wire isOr = (op == 31) & (xop10 == 444);
	wire isAddi = (op == 14);
	wire isB = (op == 18);
	wire isBC = (op == 16);
	wire isBCLR = (op == 19) && (xop10 == 16);
	wire isLD = (op == 58) & (xop2 == 0);
	wire isLDU = (op == 58) & (xop2 == 1) & (ra!=0) & (ra!=rt);
	wire isSC = (op == 17);
	wire isSTD = (op == 62) & (xop2 == 0);
	wire isSTDU = (op == 62) & (xop2 == 1) & (ra!=0);
	wire isMTSPR = (op == 31) & (xop10 == 467);
	wire isMFSPR = (op == 31) & (xop10 == 339);
	wire isMTCRF = (op == 31) & (xop10 == 144);
	wire isOther = !(isAdd|isOr|isAddi|isB|isBC|isBCLR|isLD|isLDU|
			isSC|isSTD|isSTDU|isMTSPR|isMFSPR|isMTCRF);

	reg [0:31] instrE;
	wire [0:5] opE = instrE [0:5];
	wire [0:8] xop9E = instrE [22:30];
	wire [0:9] xop10E = instrE [21:30];
	wire [0:1] xop2E = instrE [30:31];
	
	wire [0:4] rtE = instrE [6:10];
	wire [0:4] raE = instrE [11:15];
	wire [0:4] rbE = instrE [16:20];
	wire oeE = instrE [21];
	wire rcE = instrE [31];
	wire [0:4] rsE = instrE [6:10];
	wire [0:63] siE = { {48{instrE [16]}} , instrE [16:31]};
	wire [0:63] liE= { {38{instrE [6]}}, instrE [6:29], 2'b00};
	wire aaE = instrE [30];
	wire lkE = instrE [31];
	wire [0:4] boE = instrE [6:10];
	wire [0:4] biE = instrE [11:15];
	wire [0:63] bdE = { { {48{instrE [16]}}, instrE [16:29]}, 2'b00};
	wire bhE = instr[19];
	wire [0:63] dsE = { {48{instrE [16]}} , instrE [16:29], 2'b00};

	wire isAddE = (opE == 31) & (xop9E == 266);
	wire isOrE = (opE == 31) & (xop10E == 444);
	wire isAddiE = (opE == 14);
	wire isBE = (opE == 18);
	wire isBCE = (opE == 16);
	wire isBCLRE = (opE == 19) && (xop10E == 16);
	wire isLDE = (opE == 58) & (xop2E == 0);
	wire isLDUE = (opE == 58) & (xop2E == 1) & (raE!=0) & (raE!=rtE);
	wire isSCE = (opE == 17);
	wire isSTDE = (opE == 62) & (xop2E == 0);
	wire isSTDUE = (opE == 62) & (xop2E == 1) & (raE!=0);
	wire isMTSPRE = (opE == 31) & (xop10E == 467);
	wire isMFSPRE = (opE == 31) & (xop10E == 339);
	wire isMTCRFE = (opE == 31) & (xop10E == 144);
	wire isOtherE = !(isAddE|isOrE|isAddiE|isBE|isBCE|isBCLRE|isLDE|isLDUE|isSCE);
    	
	reg [0:31] instrWB;
	wire [0:5] opWB = instrWB [0:5];
	wire [0:8] xop9WB = instrWB [22:30];
	wire [0:9] xop10WB = instrWB [21:30];
	wire [0:1] xop2WB = instrWB [30:31];

	wire [0:4] rtWB = instrWB [6:10];
	wire [0:4] raWB = instrWB [11:15];
	wire [0:4] rbWB = instrWB [16:20];
	wire oeWB = instrWB[21];
	wire rcWB = instrWB[31];
	wire [0:4] rsWB = instrWB [6:10];
	wire [0:63] siWB = { {48{instrWB [16]}} , instrWB [16:31]};
	wire [0:63] liWB = { {38{instrWB[6]}}, instrWB [6:29], 2'b00};
	wire aaWB = instrWB [30];
	wire lkWB = instrWB [31];
	wire [0:4] boWB = instrWB [6:10];
	wire [0:4] biWB = instrWB [11:15];
	wire [0:63] bdWB = { { {48{instrWB [16]}}, instrWB [16:29]}, 2'b00};
	wire bhWB = instrWB[19];
	wire [0:63] dsWB = { {48{instrWB [16]}} , instrWB [16:29], 2'b00};
	wire [0:5] sprWB = instrWB [11:15] | instrWB [16:20];
	wire [0:7] lev = instrWB [20:26];
	wire [0:7] fxm = instrWB [12:19];
	

	wire isAddWB = (opWB == 31) & (xop9WB == 266);
	wire isOrWB = (opWB == 31) & (xop10WB == 444);
	wire isAddiWB = (opWB == 14);
	wire isBWB = (opWB == 18);
	wire isBCWB = (opWB == 16);
	wire isBCLRWB = (opWB == 19) && (xop10WB == 16);
	wire isLDWB = (opWB == 58) & (xop2WB == 0);
	wire isLDUWB = (opWB == 58) & (xop2WB == 1) & (raWB!=0) & (raWB!=rtWB);
	wire isSCWB = (opWB == 17);
	wire isSTDWB = (opWB == 62) & (xop2WB == 0);
	wire isSTDUWB = (opWB == 62) & (xop2WB == 1) & (raWB!=0);
	wire isMTSPRWB = (opWB == 31) & (xop10WB == 467);
	wire isMFSPRWB = (opWB == 31) & (xop10WB == 339);
	wire isMTCRFWB = (opWB == 31) & (xop10WB == 144);

	wire isBranchingWB = (isBWB|((isBCWB|isBCLRWB)&&cond_okWB&&ctr_okWB));
	wire isOtherWB = !(isAddWB|isOrWB|isAddiWB|isBWB|isBCWB|isBCLRWB|
				isLDWB|isLDUWB|isSCWB|isSTDWB|isSTDUWB|isMTSPRWB|
					isMFSPRWB|isMTCRFWB);
	
    	assign regWriteEn0 = (isAddWB|isOrWB|isAddiWB|isLDWB|isLDUWB|isMFSPRWB)&&!nopWB;
	assign regWriteEn1 = (isLDUWB|isSTDUWB)&&!nopWB;
	assign memWriteEn = (isSTDWB|isSTDUWB)&&!nopWB;
    	wire [0:4] targetWriteAddr0WB = isAddWB ? rtWB : 
					isOrWB ? raWB :
					isAddiWB ? rtWB : 
					(isLDWB|isLDUWB) ? rtWB :
					isMFSPRWB ? rtWB : 0;
	wire [0:4] targetWriteAddr1WB = raWB;
	wire [0:63] eaWB = (raWB==0) ? dsWB : ravWB + dsWB;
	wire [0:63] ra0WB = (raWB==0) ? siWB : ravWB + siWB;
	wire [0:63] eav = (Ago1memWriteEn&&(Ago1memWriteAddr==eaWB[0:60])) ? Ago1memWriteData :
			memReadData1;
	wire [0:63] targetVal1 = 	isAddWB ? ravWB + rbvWB :
					isOrWB ? rsvWB | rbvWB :
					isAddiWB ? ra0WB : 
					(isLDWB|isLDUWB) ? eav : 
					(isMFSPRWB&&sprWB==1) ? xer : 
					(isMFSPRWB&&sprWB==8) ? lr :
					(isMFSPRWB&&sprWB==9) ? ctr : 0;
	wire [0:63] targetVal2 =  isLDUWB|isSTDUWB ? eaWB : 0;

    	assign regReadEn0 = (isAdd|isOr|isAddi|isLD|isLDU|isSC|isSTD|isSTDU|isMTSPR|isMTCRF);
    	assign regReadAddr0 = 	isAdd ? ra :
				isOr ? rs :
				isAddi ? ra :
				(isLD|isLDU) ? ra : 
				isSC ? 0 :
				(isSTD|isSTDU) ? ra :
				isMTSPR ? rs :
				isMTCRF ? rs : 0;
	
	assign regReadEn1 = (isAdd|isOr|isSC|isSTD|isSTDU);
	assign regReadAddr1 = 	isAdd ? rb : 
				isOr ? rb : 
				isSC ? 3 :
				(isSTD|isSTDU) ? rs : 0;
	reg [0:63] run1 = 0;
//						EXECUTE	
	wire [0:63] rav = 	(isAddE|isAddiE|isLDE|isLDUE|isSCE|isSTDE|isSTDUE) ? 
					(regWriteEn0&&targetWriteAddr0WB==raE&&run1>2) ? targetVal1 :
					(regWriteEn1&&targetWriteAddr1WB==raE&&run1>2) ? targetVal2 :
					(Ago1WriteEn0&&Ago1WriteAddr0==raE&&run1>3) ? Ago1WriteData0 :
					(Ago1WriteEn1&&Ago1WriteAddr1==raE&&run1>3) ? Ago1WriteData1 :
					regReadData0 : 0;
	wire [0:63] rbv = 	(isAddE|isOrE|isSCE) ?
					(regWriteEn0&&targetWriteAddr0WB==rbE&&(run1>2)) ? targetVal1 :
					(regWriteEn1&&targetWriteAddr1WB==rbE&&(run1>2)) ? targetVal2 :
					(Ago1WriteEn0&&Ago1WriteAddr0==rbE&&(run1>3)) ? Ago1WriteData0 :
					(Ago1WriteEn1&&(Ago1WriteAddr1==rbE)&&(run1>3)) ? Ago1WriteData1 :
					regReadData1 : 0;
	wire [0:63] rsv = 	(isOrE|isSTDE|isSTDUE|isMTSPRE|isMTCRFE) ?
					(regWriteEn0&&targetWriteAddr0WB==rsE&&(run1>2)) ? targetVal1 :
					(regWriteEn1&&targetWriteAddr1WB==rsE&&(run1>2)) ? targetVal2 :
					(Ago1WriteEn0&&Ago1WriteAddr0==rsE&&(run1>3)) ? Ago1WriteData0 :
					(Ago1WriteEn1&&Ago1WriteAddr1==rsE&&(run1>3)) ? Ago1WriteData1 :
					(isOrE|isMTSPRE|isMTCRFE) ? regReadData0 :
					regReadData1 : 0;
	wire [0:63] ea = (raE==0) ? dsE : rav + dsE;
	wire [0:63] ra0 = (raE==0) ? siE : rav + siE;
	wire [0:63] reg0 = (regWriteEn0&&targetWriteAddr0WB==0) ? targetVal1 :
					(regWriteEn1&&targetWriteAddr1WB==0) ? targetVal2 :
					(Ago1WriteEn0&&Ago1WriteAddr0==0) ? Ago1WriteData0 :
					(Ago1WriteEn1&&Ago1WriteAddr1==0) ? Ago1WriteData1 :
					regReadData0;
	wire [0:63] reg3 = (regWriteEn0&&targetWriteAddr0WB==3) ? targetVal1 :
					(regWriteEn1&&targetWriteAddr1WB==3) ? targetVal2 :
					(Ago1WriteEn0&&Ago1WriteAddr0==3) ? Ago1WriteData0 :
					(Ago1WriteEn1&&Ago1WriteAddr1==3) ? Ago1WriteData1 :
					regReadData1;
//						MEMORY
    	assign memReadEn1 = (isLDE|isLDUE);
    	assign memReadAddr1 = ea [0:60];
//						WRITEBACK
	reg [0:63] ravWB=0;
	reg [0:63] rbvWB=0;
	reg [0:63] rsvWB=0;
	reg [0:63] reg0WB=0;
	reg [0:63] reg3WB=0;
	reg Ago1WriteEn0=-1;
	reg [0:4] Ago1WriteAddr0=-1;
	reg [0:63] Ago1WriteData0=-1;
	reg Ago1WriteEn1=-1;
	reg [0:4] Ago1WriteAddr1=-1;
	reg [0:63] Ago1WriteData1=-1;
	reg Ago1memWriteEn=-1;
	reg [0:60] Ago1memWriteAddr=-1;
	reg [0:63] Ago1memWriteData=-1;
		
	wire isAA = (aaWB==1);
	wire isLK = (lkWB==1);
	wire isRC = (rcWB==1);
	wire isOE = (oeWB==1);
	wire [0:63] branchTarget = isBWB ? 	isAA ? liWB : liWB+pcWB : 
						isBCWB ? (isAA ? bdWB : bdWB+pcWB) :
						isBCLRWB ? lr :
						0;
	wire ctr_okWB = boWB[2] | ((ctr!=1)^boWB[3]);
	wire cond_okWB = boWB[0] | (crWB[biWB]==boWB[1]);
	wire [0:8] reg3charWB = reg3WB [56:63];

	wire [0:63] nextXER = isMTSPRWB&&(sprWB==1) ? rsvWB : nextXER; 
	wire ov = ((ravWB[0]==1)&&(rbvWB[0]==1)&&targetVal1[0]==0)|
			((ravWB[0]==0)&&(rbvWB[0]==0)&&targetVal1[0]==1)
			? 1 : 0;
	wire [0:63] nextCTR = isMTSPRWB&&(sprWB==9) ? rsvWB : ctr;
	wire [0:63] nextLR = isMTSPRWB&&(sprWB==8) ? rsvWB : lr;

    	assign regWriteAddr0 = 	isAddWB ? rtWB : 
				isOrWB ? raWB :
				isAddiWB ? rtWB : 
				(isLDWB|isLDUWB) ? rtWB : 
				isMFSPRWB ? rtWB : 0;
    	assign regWriteData0 = targetVal1;
	
	assign regWriteAddr1 = raWB;
	assign regWriteData1 = targetVal2;
	
	assign memWriteAddr = eaWB [0:60];
	assign memWriteData = rsvWB;

	assign halt = (isSCWB) && (instrWB[30]==1) && (reg0WB == 1);

endmodule
