pragma solidity ^0.5.1;

contract Agent {
    
    struct patient {

        string name;
        uint age;
        address[] doctorAccessList;
        string patient_address;
        string patient_number;
        string patient_bloodgroup;
        uint[] diagnosis;
        string record;
    }
    
    struct doctor {
        string name;
        uint age;
        address[] patientAccessList;
        string expertise;
        string doctor_number;
        string doctor_address;
        string doctor_bloodgroup;
    }

    uint Amount_Credit;

    mapping (address => doctor) doctorInfo;
    mapping (address => patient) patientInfo;
    mapping (address => uint) patient_exist;
    mapping (address => uint) doctor_exist;
    mapping (address => address) Empty;
    mapping (address => string) patientRecords;

    address[] public patientList;
    address[] public doctorList;


    function add_patient(string memory _name, uint _age, string memory _num, string memory _bg , string memory _hash, address addr) public returns(string memory)
    {
        require(patient_exist[addr] == 0);
        
        patientList.push(addr)-1;
        patient memory p;
        p.age = _age;
        p.name = _name;
        p.record = _hash;
        p.patient_number = _num;
        p.patient_bloodgroup = _bg;
        patientInfo[msg.sender] = p;
        patient_exist[addr] = 1;
        return _name;
    }

    function add_doctor(string memory _name, uint _age, string memory _num, string memory _bg, address addr) public returns(string memory)
    {
        require(doctor_exist[addr] == 0);
        
        doctorList.push(addr)-1;
        doctorInfo[addr].name = _name;
        doctorInfo[addr].age = _age;
        doctorInfo[addr].doctor_number = _num;
        doctorInfo[addr].doctor_bloodgroup = _bg;
        doctor_exist[addr] = 1;
        return _name;
    }

    function add_agent(string memory _name, uint _age, uint _designation, string memory _num, string memory _bg, string memory _hash) public returns(string memory)
    {
        address addr = msg.sender;
        
        if(_designation == 0)
        {
            return add_patient(_name, _age, _num, _bg, _hash, addr);
        }
       else if (_designation == 1)
       {
            return add_doctor(_name, _age, _num, _bg, addr);
       }
       else
       {
           revert();
       }
    }

    function get_doctor(address addr) view public returns (string memory , uint, string memory, string memory)
    {
        return (doctorInfo[addr].name, doctorInfo[addr].age, doctorInfo[addr].doctor_number, doctorInfo[addr].doctor_bloodgroup);
    }

    function get_patient(address addr) view public returns (string memory , uint, uint[] memory , address, string memory )
    {
        return (patientInfo[addr].name, patientInfo[addr].age, patientInfo[addr].diagnosis, Empty[addr], patientInfo[addr].record);
    }

    function permit_access(address addr) payable public
    {
        require(msg.value == 2 ether);
        
        patientInfo[msg.sender].doctorAccessList.push(addr)-1;   
        doctorInfo[addr].patientAccessList.push(msg.sender)-1;
        Amount_Credit += 2;
    }


    function daignosis_submit_action(address paddr, uint _diagnosis, string memory  _hash) public
    {
        bool flag = false;
        for(uint i = 0;i<doctorInfo[msg.sender].patientAccessList.length;i++)
        {
            if(doctorInfo[msg.sender].patientAccessList[i]==paddr)
            {
                set_hash(paddr, _hash);
                remove_patient(paddr, msg.sender);
                msg.sender.transfer(2 ether);
                Amount_Credit -= 2;
                flag = true;
                break;
            }
            
        }
        if(flag==false)
        {
            revert();
        }

        bool DiagnosisFound = false;
        for(uint j = 0; j < patientInfo[paddr].diagnosis.length;j++)
        {
            if(patientInfo[paddr].diagnosis[j] == _diagnosis)
                DiagnosisFound = true;
        }
    }


    function remove_element_in_array(address[] storage Array, address addr) internal returns(uint)
    {
        bool check = false;
        uint del_index = 0;
        for(uint i = 0; i<Array.length; i++)
        {
            if(Array[i] == addr)
            {
                check = true;
                del_index = i;
            }
        }
        
        if(!check) 
        {
            revert();
        }
        else
        {
            if(Array.length != 1)
            {
                Array[del_index] = Array[Array.length - 1];
                delete Array[Array.length - 1];
            }
            else
            {
                delete Array[del_index];
            }
            Array.length--;
        }
    }


    function get_accessed_patientlist_for_doctor(address addr) public view returns (address[] memory )
    {
        return doctorInfo[addr].patientAccessList;
    }

    function get_accessed_doctorlist_for_patient(address addr) public view returns (address[] memory )
    { 
        address[] storage doctoraddr = patientInfo[addr].doctorAccessList;
        return doctoraddr;
    }

    function getBasicPatientInfo (address patientId) public view returns(string memory patientName, string memory patientAddress, string memory patientBloodgroup, 
               string memory patientPhoneNo)  
    {
        require(patient_exist[patientId]==1);
        return(patientInfo[patientId].name, patientInfo[patientId].patient_address, patientInfo[patientId].patient_bloodgroup, 
               patientInfo[patientId].patient_number);
       
    }

    function remove_patient(address paddr, address daddr) public 
    {
        remove_element_in_array(patientInfo[paddr].doctorAccessList, daddr);
        remove_element_in_array(doctorInfo[daddr].patientAccessList, paddr);
    }

    function revoke_access(address daddr) public payable
    {
        remove_patient(msg.sender,daddr);
        msg.sender.transfer(2 ether);
        Amount_Credit -= 2;
    }
    
    function get_hash(address paddr) public view returns(string memory)
    {
        return patientInfo[paddr].record;
    }

    function updateDoctorDetails(address doc_id,string memory _name,string memory _phoneNumber,string memory _address) public {
        doctorInfo[doc_id].name = _name; 
        doctorInfo[doc_id].doctor_number = _phoneNumber; 
        doctorInfo[doc_id].doctor_address = _address; 
    }

    function set_hash(address paddr, string memory _hash) internal 
    {
        patientInfo[paddr].record = _hash;
    }

    function get_doctor_list() public view returns(address[] memory )
    {
        return doctorList;
    }


    function get_patient_list() public view returns(address[] memory )
    {
        return patientList;
    }

}

