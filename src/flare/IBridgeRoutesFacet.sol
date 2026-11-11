// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IBridgeRoutesFacet
 * @notice Interface for the BridgeRoutesFacet contract: the Flare-side, governance-set routing
 * for everything that bridges FXRP or sends a compose message from an account here to that same
 * account's address on a remote chain — the subaccounts of every type and the Personal Account's
 * cross-chain user operations. Three records: the one FXRP OFT adapter on Flare, one pinned peer
 * per remote chain (a route), and the remote chain each subaccount type lives on. The Flare
 * counterpart of the remote diamonds' {IComposeTransportFacet}: a transport says how composes
 * arrive on a remote, a route says where sends go from here. Cut only on the Flare diamond.
 * @dev Routes are governance-set rather than supplied by the caller, so that no caller can choose
 * where assets are bridged: a subaccount's destination is the route of its type, and a Personal
 * Account's cross-chain user operation names a destination endpoint that must be a registered
 * route. Every send also re-checks the OFT's live peer for the destination against the pinned one,
 * so a peer mutation on the adapter after configuration fails the sends closed instead of routing
 * to an unknown remote OApp.
 */
interface IBridgeRoutesFacet {

    /**
     * @notice Emitted when the FXRP OFT adapter is set or cleared.
     * @param fxrpOft The FXRP OFT adapter; zero when cleared.
     */
    event FxrpOftSet(
        address fxrpOft
    );

    /**
     * @notice Emitted when a route is set or cleared.
     * @param destinationEid The LayerZero endpoint id of the remote chain.
     * @param destinationPeer The pinned peer on that chain; zero when the route is cleared.
     */
    event BridgeRouteSet(
        uint32 destinationEid,
        bytes32 destinationPeer
    );

    /**
     * @notice Emitted when a subaccount type is pinned to the remote chain it lives on. Once,
     * per type: the pin is write-once. Only the types that bridge get one; a Flare-local type
     * (a vault subaccount, say) never does.
     * @param subaccountType The subaccount type.
     * @param destinationEid The route's endpoint id.
     */
    event SubaccountTypeRouteSet(
        uint256 subaccountType,
        uint32 destinationEid
    );

    /**
     * @notice Emitted when a pinned type's route is suspended or resumed.
     * @param subaccountType The subaccount type.
     * @param suspended Whether the type's forward moves are now blocked.
     */
    event SubaccountTypeRouteSuspended(
        uint256 subaccountType,
        bool suspended
    );

    /**
     * @notice Reverts if the FXRP OFT address is invalid: not a contract, not wrapping FXRP, not
     * sharing its decimals, or reporting a non-canonical interface/message-codec version.
     */
    error InvalidFxrpOft();

    /**
     * @notice Reverts if a route is set while no FXRP OFT adapter is configured.
     */
    error FxrpOftNotConfigured();

    /**
     * @notice Reverts if the destination endpoint id is zero.
     */
    error InvalidDestinationEid();

    /**
     * @notice Reverts if the destination peer has dirty upper bits (not a clean zero-padded EVM
     * address), or does not match the OFT's live peer for the destination endpoint.
     */
    error InvalidDestinationPeer();

    /**
     * @notice Reverts an attempt to re-point a subaccount type at a different chain. The pin is
     * write-once: the type is the (chain, product) identity its positions live under, and its
     * signed instructions carry no destination, so re-pointing would route an already-signed
     * action to another chain. A second chain is a second type; to stop a pinned type's
     * forward moves, suspend it.
     * @param subaccountType The subaccount type.
     * @param destinationEid The endpoint id it is already pinned to.
     */
    error SubaccountTypeRoutePinned(
        uint256 subaccountType,
        uint32 destinationEid
    );

    /**
     * @notice Reverts if a subaccount type is first pinned to an endpoint id that has no route,
     * or (with a zero id) if an unpinned type is suspended.
     * @param destinationEid The unregistered endpoint id.
     */
    error UnknownBridgeRoute(
        uint32 destinationEid
    );

    /**
     * @notice Returns the FXRP OFT adapter every route sends through.
     * @return The adapter; zero when not configured.
     */
    function getFxrpOft()
        external view
        returns (address);

    /**
     * @notice Returns the pinned peer of a route.
     * @param _destinationEid The LayerZero endpoint id of the remote chain.
     * @return The pinned peer on that chain; zero when no route exists for the endpoint.
     */
    function getBridgeRoute(
        uint32 _destinationEid
    )
        external view
        returns (bytes32);

    /**
     * @notice Returns every registered route.
     * @dev The order is unspecified (clearing a route swaps the last one into its place); the
     * two arrays are index-aligned.
     * @return _destinationEids The endpoint ids.
     * @return _destinationPeers The pinned peers, aligned with `_destinationEids`.
     */
    function getBridgeRoutes()
        external view
        returns (uint32[] memory _destinationEids, bytes32[] memory _destinationPeers);

    /**
     * @notice Returns the route a subaccount type bridges over, if it bridges at all.
     * @dev The tuple a subaccount needs to send and to authenticate its own bridge-back: the
     * adapter, the endpoint id its type is pinned to, and that route's pinned peer. Any zero
     * member means the type is not routable right now (no adapter, a type never pinned, a
     * cleared route, or a suspended type - a suspension answers as a zero endpoint id, while
     * the pin itself survives in {getSubaccountTypeRoutePin}).
     * @param _subaccountType The subaccount type.
     * @return _fxrpOft The FXRP OFT adapter.
     * @return _destinationEid The endpoint id of the type's remote chain.
     * @return _destinationPeer The pinned peer there.
     */
    function getSubaccountTypeRoute(
        uint256 _subaccountType
    )
        external view
        returns (address _fxrpOft, uint32 _destinationEid, bytes32 _destinationPeer);

    /**
     * @notice Returns a subaccount type's write-once chain pin and whether it is suspended.
     * @dev For governance and tooling: {getSubaccountTypeRoute} answers "can this type send
     * now", which a suspension turns to zero; this one still shows where the type's positions
     * live. A zero endpoint id means the type was never pinned.
     * @param _subaccountType The subaccount type.
     * @return _destinationEid The endpoint id the type is pinned to, or zero.
     * @return _suspended Whether the type's forward moves are suspended.
     */
    function getSubaccountTypeRoutePin(
        uint256 _subaccountType
    )
        external view
        returns (uint32 _destinationEid, bool _suspended);
}
