// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IComposeTransportFacet
 * @notice The compose transport of a remote diamond: one record per diamond naming the
 * LayerZero endpoint that may call `lzCompose`, the OFT that must be the compose sender, the
 * origin chain and the pinned peer there. Every compose receiver on the diamond — the remote
 * Personal Account and every remote subaccount type — authenticates against it, so it is the
 * security root of every action that arrives without a local signature. One route per
 * diamond: a token bridged through a different OFT would need a transport per route, which is
 * a schema change, not a setting. Cut only on remote diamonds (the loan chain, Ethereum, at
 * launch).
 * @dev The transport is written under the timelock and cleared immediately: the clear is the
 * containment lever for a compromised endpoint, OFT or peer, and a lever behind a timelock is
 * not one. The clear does not cancel queued `setComposeTransport` calls (the timelock keys them
 * by calldata hash and lets anyone execute a matured one - cancel them first), and it does not
 * retire compose packets already queued at the endpoint (a delivery that reverts against a
 * cleared transport stays retriable). The incident runbook is therefore: pause, cancel queued
 * transport sets, clear, and later set a replacement transport that rotates the compromised
 * identity - the exact compromised tuple is never restored, or packets forged under it would
 * pass authentication again.
 */
interface IComposeTransportFacet {

    /// @dev The compose transport: how authenticated actions arrive and, for the remote loan
    /// subaccount, how the bridge-back leaves. One per diamond, shared by every compose
    /// receiver on it.
    struct Transport {
        /// @notice The LayerZero EndpointV2: the only allowed `lzCompose` caller.
        address lzEndpoint;
        /// @notice The OFT on this chain: the only allowed compose sender (`_from`), the
        /// authoritative identity of the bridged token (`token()`), and the vehicle of the
        /// bridge-back.
        address oft;
        /// @notice The LayerZero endpoint id of the origin chain (Flare).
        uint32 originEid;
        /// @notice The pinned peer on the origin chain (the Flare-side OFT adapter); the
        /// bridge-back re-checks the live peer against it on every call.
        bytes32 originPeer;
    }

    /**
     * @notice Emitted when the compose transport is set.
     * @param lzEndpoint The LayerZero endpoint.
     * @param oft The OFT.
     * @param originEid The origin (Flare) endpoint id.
     * @param originPeer The pinned origin peer.
     */
    event ComposeTransportSet(
        address lzEndpoint,
        address oft,
        uint32 originEid,
        bytes32 originPeer
    );

    /**
     * @notice Emitted when the compose transport is cleared.
     */
    event ComposeTransportCleared();

    /**
     * @notice Reverts if the LayerZero endpoint is not a contract, or is not the endpoint the
     * OFT is wired to.
     */
    error InvalidLzEndpoint();

    /**
     * @notice Reverts if the origin endpoint id is zero.
     */
    error InvalidOriginEid();

    /**
     * @notice Reverts if the origin peer is zero, has dirty upper bits (not a clean
     * zero-padded EVM address), or does not match the OFT's live peer for the origin endpoint.
     */
    error InvalidOriginPeer();

    /**
     * @notice Reverts if the OFT is not a contract, its shared decimals differ from its own
     * token's, it reports a non-canonical interface/message-codec version, or - once a token
     * is pinned - it wraps a different token.
     */
    error InvalidOft();

    /**
     * @notice Reverts when an operation needs the compose transport and it is not configured.
     */
    error ComposeTransportNotConfigured();

    /**
     * @notice Returns the compose transport.
     * @return The transport; all-zero when not configured.
     */
    function getComposeTransport()
        external view
        returns (Transport memory);
}
