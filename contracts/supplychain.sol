// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {

    // Estrutura que define um Produto
    struct Product {
        uint256 id;                      // ID único do produto
        string name;                     // Nome do produto
        string description;              // Descrição detalhada
        string manufacturer;             // Fabricante
        uint256 manufactureDate;         // Data de fabricação (timestamp)
        string batchNumber;              // Número do lote
        address currentOwner;            // Endereço do proprietário atual
        address[] ownershipHistory;      // Histórico de proprietários
        string[] locationHistory;        // Histórico de localizações
        bool exists;                     // Verifica se o produto existe
    }

    // Mapeamento de IDs de produtos para Produtos
    mapping(uint256 => Product) private products;

    // Eventos para registrar atividades importantes
    event ProductRegistered(uint256 indexed id, string name, address indexed owner);
    event OwnershipTransferred(uint256 indexed id, address indexed from, address indexed to);
    event LocationUpdated(uint256 indexed id, string location);

    // Modificador para verificar se o produto existe
    modifier productExists(uint256 _id) {
        require(products[_id].exists, "Produto nao existe.");
        _;
    }

    // Modificador para verificar se o chamador é o proprietário atual
    modifier onlyOwner(uint256 _id) {
        require(products[_id].currentOwner == msg.sender, "Apenas o proprietario atual pode executar esta acao.");
        _;
    }

    // Função para registrar um novo produto
    function registerProduct(
        uint256 _id,
        string memory _name,
        string memory _description,
        string memory _manufacturer,
        uint256 _manufactureDate,
        string memory _batchNumber,
        string memory _initialLocation
    ) public {
        require(!products[_id].exists, "Produto com este ID ja existe.");

        // Cria uma instância do produto
        Product storage newProduct = products[_id];

        // Atribui os valores
        newProduct.id = _id;
        newProduct.name = _name;
        newProduct.description = _description;
        newProduct.manufacturer = _manufacturer;
        newProduct.manufactureDate = _manufactureDate;
        newProduct.batchNumber = _batchNumber;
        newProduct.currentOwner = msg.sender;
        newProduct.exists = true;

        // Inicializa os históricos
        newProduct.ownershipHistory.push(msg.sender);
        newProduct.locationHistory.push(_initialLocation);

        emit ProductRegistered(_id, _name, msg.sender);
    }

    // Função para transferir a propriedade do produto
    function transferOwnership(uint256 _id, address _newOwner) public productExists(_id) onlyOwner(_id) {
        Product storage product = products[_id];
        address previousOwner = product.currentOwner;
        product.currentOwner = _newOwner;
        product.ownershipHistory.push(_newOwner);

        emit OwnershipTransferred(_id, previousOwner, _newOwner);
    }

    // Função para atualizar a localização do produto
    function updateLocation(uint256 _id, string memory _newLocation) public productExists(_id) onlyOwner(_id) {
        Product storage product = products[_id];
        product.locationHistory.push(_newLocation);

        emit LocationUpdated(_id, _newLocation);
    }

    // Função para obter informações do produto
    function getProduct(uint256 _id) public view productExists(_id) returns (
        uint256 id,
        string memory name,
        string memory description,
        string memory manufacturer,
        uint256 manufactureDate,
        string memory batchNumber,
        address currentOwner
    ) {
        Product storage product = products[_id];
        return (
            product.id,
            product.name,
            product.description,
            product.manufacturer,
            product.manufactureDate,
            product.batchNumber,
            product.currentOwner
        );
    }

    // Função para obter o histórico de proprietários
    function getOwnershipHistory(uint256 _id) public view productExists(_id) returns (address[] memory) {
        return products[_id].ownershipHistory;
    }

    // Função para obter o histórico de localizações
    function getLocationHistory(uint256 _id) public view productExists(_id) returns (string[] memory) {
        return products[_id].locationHistory;
    }
}