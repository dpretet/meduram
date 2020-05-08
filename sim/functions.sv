/// Check if the agent index to use are correct
task checkAgent(input integer agent);
    if (agent < AGENT1) begin
        `ERROR("Agent index can't lower than 1");
        $finish;
    end
    // Finish simulation if don't use a correct index
    if (agent > AGENT2) begin
        `ERROR("No more than 2 agents are supported in this testbench");
        $finish;
    end
endtask

/// Task to write a memory address by selecting the agent to use
task writeAgent(input integer agent, input integer addr, input integer data);
begin
    `ifdef VERBOSE
        string msg;
        $sformat(msg, "Write access start with agent %0d", agent);
        `INFO(msg);
    `endif
    checkAgent(agent);

    // Wait for posedge and write a data into memory
    @ (posedge aclk);
    if (agent == AGENT1) begin
        wren1 = 1'b1;
        wraddr1 = addr;
        wrdata1 = data;
    end 
    if (agent == AGENT2) begin
        wren2 = 1'b1;
        wraddr2 = addr;
        wrdata2 = data;
    end

    // Deassert the xfer after one cycle
    @ (posedge aclk);
    if (agent == AGENT1) wren1 = 1'b0;
    if (agent == AGENT2) wren2 = 1'b0;
    `ifdef VERBOSE
        `INFO("Write access done");
    `endif
end
endtask

/// Task to read a memory address with a specific agent
task readAgent(input integer agent, input integer addr, output integer value);
begin
    `ifdef VERBOSE
        string msg;
        $sformat(msg, "Read access start with agent %0d", agent);
        `INFO(msg);
    `endif
    checkAgent(agent);

    // Wait for posedge and read a memory address
    @ (posedge aclk);
    if (agent == AGENT1) begin
        rden1 = 1'b1;
        rdaddr1 = addr;
    end 
    if (agent == AGENT2) begin
        rden2 = 1'b1;
        rdaddr2 = addr;
    end

    // Deassert the request and read data
    @ (posedge aclk);
    @ (negedge aclk);
    if (agent == AGENT1) begin
        rden1 = 1'b0;
        value = rddata1;
    end 
    if (agent == AGENT2) begin
        rden2 = 1'b0;
        value = rddata2;
    end
    `ifdef VERBOSE
        $sformat(msg, "Value read: %x", value);
        `INFO(msg);
        `INFO("Read access done");
    `endif
end
endtask

/// get a random agent index
function integer pickRandomAgent();
    integer ix;
    ix = $urandom() % 3;
    if (ix<1) ix = AGENT1;
    if (ix>2) ix = AGENT2;
    pickRandomAgent = ix; 
endfunction

/// get a random address
function integer pickRandomAddr();
    integer _rand;
    _rand = $urandom();
    if (_rand >= RAM_DEPTH)
        _rand = RAM_DEPTH - 1;
    pickRandomAddr = _rand;
endfunction
