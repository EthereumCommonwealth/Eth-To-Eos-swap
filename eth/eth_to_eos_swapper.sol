pragma solidity ^0.4.25;


contract EthToEosSwaplinker {
    event SwapToEOS(address indexed _from, string indexed _to, uint _amount, string _data);
    event SwapFromEOS(address indexed _from, string indexed _to, uint _amount, string _data);
    event SwapRejected(address indexed _from, string indexed _to, uint _amount, string _data);
    event RequestSwap(address indexed _from, string indexed _to, uint _amount, string _data);
    
    address public owner = msg.sender;
    uint    public swapped_to_eos = 0;
    
    modifier only_owner
    {
        require(msg.sender == owner);
        _;
    }
    
    struct crosschain_link
    {
        string  eos_address;
        
        bool    exist;
        
        uint    pending_to_eos;
        uint    pending_withdrawal;
        string  swap_metadata;
    }
    
    mapping (address => crosschain_link) public crosschain_links;
    mapping (uint => address)            public crosschain_links_indexed;
    
    uint public active_links = 0;
    
    
    function()
    {
        revert();
    }
    
    function link(string eos_address)
    {
        require(crosschain_links[msg.sender].pending_withdrawal == 0);
        require(crosschain_links[msg.sender].pending_to_eos == 0);
        
        if(crosschain_links[msg.sender].exist == false)
        {
            crosschain_links_indexed[active_links] = msg.sender;
            active_links++;
        }
        
        crosschain_links[msg.sender].exist = true;
        crosschain_links[msg.sender].eos_address = eos_address;
    }
    
    function request_swap(string eos_address, string data) payable
    {
        require(crosschain_links[msg.sender].exist);
        
        crosschain_links[msg.sender].pending_to_eos += msg.value;
        crosschain_links[msg.sender].swap_metadata   = data;
        
        emit RequestSwap(msg.sender, eos_address, msg.value, data);
    }
    
    function request_withdrawal(string eos_address, string data)
    {
        require(crosschain_links[msg.sender].exist);
        require(crosschain_links[msg.sender].pending_withdrawal > 0);
        
        uint amount_to_withdraw = crosschain_links[msg.sender].pending_withdrawal;
        crosschain_links[msg.sender].pending_withdrawal = 0;
        
        msg.sender.transfer(amount_to_withdraw);
    }
    
    function request_swap_cancel(string eos_address, string data)
    {
        require(crosschain_links[msg.sender].exist);
        
        crosschain_links[msg.sender].pending_withdrawal += crosschain_links[msg.sender].pending_to_eos;
        crosschain_links[msg.sender].pending_to_eos = 0;
    }
    
    function process_swap_to_eos(address clo_address, string eos_address, uint amount, string data) only_owner
    {
        require(crosschain_links[clo_address].exist);
        require(crosschain_links[clo_address].pending_to_eos == amount);
        
        swapped_to_eos += amount;
        crosschain_links[clo_address].pending_to_eos = 0;
        
        emit SwapToEOS(clo_address, eos_address, amount, data);
    }
    
    function process_swap_from_eos(address clo_address, string eos_address, uint amount, string data) only_owner
    {
        swapped_to_eos -= amount;
        crosschain_links[clo_address].pending_withdrawal = amount;
        
        emit SwapFromEOS(clo_address, eos_address, amount, data);
    }
    
    function reject_swap(address clo_address, string eos_address, uint amount, string data) only_owner
    {
        require(crosschain_links[clo_address].exist);
        require(crosschain_links[clo_address].pending_to_eos >= amount);
        
        crosschain_links[clo_address].pending_withdrawal += crosschain_links[clo_address].pending_to_eos;
        crosschain_links[clo_address].pending_to_eos = 0;
        
        emit SwapRejected(clo_address, eos_address, amount, data);
    }
}
