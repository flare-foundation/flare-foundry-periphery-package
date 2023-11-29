// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {IERC20Metadata} from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";

// FTSO system
import {IFtso} from "../../coston2/ftso/userInterfaces/IFtso.sol";
import {IPriceSubmitter} from "../../coston2/ftso/userInterfaces/IPriceSubmitter.sol";
import {IFtsoRegistry} from "../../coston2/ftso/userInterfaces/IFtsoRegistry.sol";

// State connector
import {ISCProofVerifier} from "../../coston2/stateConnector/interface/ISCProofVerifier.sol";

struct ReservationInfo {
    bytes32 _paymentReference;
    string _targetAddress;
    uint256 _payableAmount;
}

contract MultiChainNft is ERC721 {
    error UnsupportedChain(string wrongChain);
    error InsufficientReservation();
    error InvalidReservation();
    error InvalidPaymentAddresss();
    error InsufficientPaymentAmount(int256 needed, int256 paid);
    error WrongPaymentReference();
    error PaymentTooOld();
    error InvalidStateConectorProof();
    error FailedPayment();

    struct Reservation {
        string chain;
        uint256 tokenId;
        uint256 payableAmount;
        uint256 reservationTime;
        bytes32 paymentReference;
        string targetChainPaymentAddress;
    }

    struct ChainInfo {
        string symbol;
        uint32 chainId;
        string targetAddress;
        uint256 maxWaitingTimeSeconds;
        uint256 decimals;
    }

    event ReservationCreated(
        address indexed account,
        uint256 indexed tokenId,
        string indexed chain,
        bytes32 paymentReference,
        string targetAddress,
        uint256 _payableAmount
    );

    event ExpiredReservationClosed(
        address indexed account,
        uint256 indexed tokenId,
        string indexed chain,
        address cancellingAddress,
        bytes32 paymentReference,
        string targetAddress,
        uint256 _payableAmount
    );

    uint256 public immutable dollarPriceWeiCost;
    uint256 weiDollarPriceDecimals = 2;

    string public constant targetAddress = "";
    string public constant nativeWnatSymbol = "CFLR2";
    uint256 public pricePremiumBIPS = 100; // 1% premium to price to account for volatility
    uint256 public premiumResolution = 4;

    mapping(uint256 => string) private _tokenURIs;

    mapping(string => ChainInfo) public chainInfo;

    mapping(address => Reservation) public reservations;

    mapping(string => string) private ftosRegistryChainMapper;

    uint256 public reservationCostWei = 10;

    uint256 public currentTokenId = 0;

    bytes32 public constant RESERVATION_SALT = keccak256("RESERVATION_SALT");

    address public immutable owner;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 _dollarPriceWeiCost
    ) ERC721(name_, symbol_) {
        owner = msg.sender;
        dollarPriceWeiCost = _dollarPriceWeiCost;
        string
            memory flareDubai = "QmRuiX2Q9ABFZJjQDZmZVyPkZvGz9qv265VYkC2YvmYxYk";
        _tokenURIs[0] = flareDubai;
        ftosRegistryChainMapper["ALGO"] = "testALGO";
        ftosRegistryChainMapper["BTC"] = "testBTC";
        ftosRegistryChainMapper["LTC"] = "testLTC";
        ftosRegistryChainMapper["XRP"] = "testXRP";
        ftosRegistryChainMapper["DOGE"] = "testDOGE";

        chainInfo["ALGO"] = ChainInfo(
            "ALGO",
            4,
            // "3DMYZ4CV5O5HMWIY6QFTXFV2U2S6DGP3KAQH2IELIBLJUBHQKT5T7X7JBA",
            "N24ISHMYKEVEIC4Q5KV2WZJAJ3IMKXU663AAUXRGQW5ZF6NVZCJ67OSBII",
            60 * 60 * 24 * 5,
            6
        );

        chainInfo["BTC"] = ChainInfo(
            "BTC",
            0,
            "Not available",
            60 * 60 * 24 * 5,
            8
        );

        chainInfo["LTC"] = ChainInfo(
            "LTC",
            1,
            "Not available",
            60 * 60 * 24 * 5,
            8
        );

        chainInfo["DOGE"] = ChainInfo(
            "DOGE",
            2,
            "nVwzA4RZLf2NfERDpgJWCsud9jVxGwNfsb",
            60 * 60 * 24 * 5,
            8
        );

        chainInfo["XRP"] = ChainInfo(
            "XRP",
            3,
            "rLnXgjeg2ZYNNcN3aEqctVudTZTsgY25B7",
            60 * 60 * 24 * 5,
            6
        );
    }

    function getPriceSubmitter() public view virtual returns (IPriceSubmitter) {
        return IPriceSubmitter(0x1000000000000000000000000000000000000003);
    }

    function getAttestationClient()
        public
        view
        virtual
        returns (ISCProofVerifier)
    {
        return ISCProofVerifier(0x8858eeB3DfffA017D4BCE9801D340D36Cf895CCf);
    }

    function getPriceInTargetCurrency(
        string memory _symbol
    ) public view returns (uint256) {
        IFtsoRegistry ftsoRegistry = IFtsoRegistry(
            address(getPriceSubmitter().getFtsoRegistry())
        );
        uint256 foreignTokenDecimalsToUsd = 5;

        ChainInfo memory info = chainInfo[_symbol];

        (uint256 foreignTokenToUsdDecimals, ) = ftsoRegistry.getCurrentPrice(
            ftosRegistryChainMapper[_symbol]
        );
        uint256 price = (dollarPriceWeiCost *
            (10 ** foreignTokenDecimalsToUsd) *
            (10 ** info.decimals)) /
            (foreignTokenToUsdDecimals * (10 ** weiDollarPriceDecimals));
        return
            (price * (10 ** premiumResolution + pricePremiumBIPS)) /
            (10 ** premiumResolution);
    }

    function calculateReservationReference(
        string memory _chainSymbol,
        uint256 _tokenId,
        address _sender
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    RESERVATION_SALT,
                    _chainSymbol,
                    _tokenId,
                    address(_sender),
                    address(this)
                )
            );
    }

    function reserveFor(
        string memory _chainSymbol,
        address target
    ) public returns (ReservationInfo memory) {
        ChainInfo memory info = chainInfo[_chainSymbol];
        if (bytes(info.symbol).length == 0) {
            revert UnsupportedChain(_chainSymbol);
        }

        // TODO: implement some locking for reservation
        // if(msg.value < reservationCostWei) {
        //     revert InsufficientReservation();
        // }

        ++currentTokenId;

        bytes32 paymentReference = calculateReservationReference(
            _chainSymbol,
            currentTokenId,
            msg.sender
        );
        uint256 _payableAmount = getPriceInTargetCurrency(info.symbol);
        reservations[target] = Reservation(
            _chainSymbol,
            currentTokenId,
            _payableAmount,
            block.timestamp,
            paymentReference,
            info.targetAddress
        );

        emit ReservationCreated(
            target,
            currentTokenId,
            _chainSymbol,
            paymentReference,
            info.targetAddress,
            _payableAmount
        );

        return
            ReservationInfo(
                paymentReference,
                info.targetAddress,
                _payableAmount
            );
    }

    function reserve(
        string memory _chainSymbol
    ) public returns (ReservationInfo memory) {
        return reserveFor(_chainSymbol, msg.sender);
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://ipfs/";
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return string(abi.encodePacked(baseURI, _tokenURIs[tokenId % 1]));
    }

    function checkProofValidity(
        ChainInfo memory _chainInfo,
        ISCProofVerifier.Payment memory _payment
    ) public view {
        // Verify that the payment is valid
        ISCProofVerifier attestationClient = getAttestationClient();
        if (!attestationClient.verifyPayment(_chainInfo.chainId, _payment)) {
            revert InvalidStateConectorProof();
        }
    }

    function checkPaymentValidity(
        ChainInfo memory _chainInfo,
        Reservation memory _reservation,
        ISCProofVerifier.Payment memory _payment
    ) public view returns (bool) {
        // Verify that _payment is the same as requested in reservation

        if (_payment.status != 0) {
            revert FailedPayment();
        }

        // Verify that the payment is to correct address
        if (
            keccak256(bytes(_reservation.targetChainPaymentAddress)) !=
            _payment.receivingAddressHash
        ) {
            revert InvalidPaymentAddresss();
        }

        // Verify that the payment has correct amount
        if (int256(_reservation.payableAmount) > _payment.receivedAmount) {
            revert InsufficientPaymentAmount(
                int256(_reservation.payableAmount),
                _payment.receivedAmount
            );
        }
        // Verify that the payment has correct reference
        if (_reservation.paymentReference != _payment.paymentReference) {
            revert WrongPaymentReference();
        }

        // Verify that the payment is not too old
        if (
            block.timestamp - _reservation.reservationTime >
            _chainInfo.maxWaitingTimeSeconds
        ) {
            revert PaymentTooOld();
        }

        return true;
    }

    function checkFullPaymentValidity(
        ISCProofVerifier.Payment memory _payment
    ) public view returns (bool) {
        Reservation memory reservation = reservations[msg.sender];
        if (reservation.reservationTime == 0) {
            revert InvalidReservation();
        }

        ChainInfo memory info = chainInfo[reservation.chain];

        checkPaymentValidity(info, reservation, _payment);

        // Verify that the payment is valid
        checkProofValidity(info, _payment);

        return true;
    }

    function mintNft(
        ISCProofVerifier.Payment memory _payment
    ) public returns (bool) {
        checkFullPaymentValidity(_payment);

        Reservation memory reservation = reservations[msg.sender];

        delete reservations[msg.sender];
        _safeMint(msg.sender, reservation.tokenId);
        return true;
    }

    function setChainInfo(
        string memory chainSymbol,
        ChainInfo memory info
    ) public {
        require(msg.sender == owner, "Only owner can set chain info");
        require(
            bytes(chainInfo[chainSymbol].symbol).length > 0,
            "Chain must alreaady exist"
        );
        chainInfo[chainSymbol] = info;
    }
}

contract TestableMultiChainNft is MultiChainNft {
    address private priceSubmitterAddress;
    address private attestationClientAddress;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 _dollarPriceWeiCost
    ) MultiChainNft(name_, symbol_, _dollarPriceWeiCost) {}

    function setPriceSubmitter(address _priceSubmitterAddress) public {
        priceSubmitterAddress = _priceSubmitterAddress;
    }

    function setAttestationClient(address _attestationClientAddress) public {
        attestationClientAddress = _attestationClientAddress;
    }

    function getPriceSubmitter()
        public
        view
        override
        returns (IPriceSubmitter)
    {
        return IPriceSubmitter(priceSubmitterAddress);
    }

    function getAttestationClient()
        public
        view
        override
        returns (ISCProofVerifier)
    {
        return ISCProofVerifier(attestationClientAddress);
    }
}
