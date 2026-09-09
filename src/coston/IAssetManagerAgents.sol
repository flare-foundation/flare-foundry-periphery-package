// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import {IPayment} from ".//IPayment.sol";
import {IAddressValidity} from ".//IAddressValidity.sol";
import {AgentInfo} from "./data/AgentInfo.sol";
import {AgentSettings} from "./data/AgentSettings.sol";
import {AvailableAgentInfo} from "./data/AvailableAgentInfo.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * Periphery-defined view of IAssetManager.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IAssetManagerAgents {
    struct AgentVaultCreationData {
        address collateralPool;
        address collateralPoolToken;
        string underlyingAddress;
        address vaultCollateralToken;
        address poolWNatToken;
        uint256 feeBIPS;
        uint256 poolFeeShareBIPS;
        uint256 mintingVaultCollateralRatioBIPS;
        uint256 mintingPoolCollateralRatioBIPS;
        uint256 buyFAssetByAgentFactorBIPS;
        uint256 poolExitCollateralRatioBIPS;
        uint256 redemptionPoolFeeShareBIPS;
    }

    /**
     * Create an agent vault.
     * The agent will always be identified by `_agentVault` address.
     * (Externally, one account may own several agent vaults,
     *  but in fasset system, each agent vault acts as an independent agent.)
     * NOTE: may only be called by an agent on the allowed agent list.
     * Can be called from the management or the work agent owner address.
     * @return _agentVault new agent vault address
     */
    function createAgentVault(
        IAddressValidity.Proof calldata _addressProof,
        AgentSettings.Data calldata _settings
    ) external
        returns (address _agentVault);

    /**
     * Announce that the agent is going to be destroyed. At this time, the agent must not have any mintings
     * or collateral reservations and must not be on the available agents list.
     * NOTE: may only be called by the agent vault owner.
     * @return _destroyAllowedAt the timestamp at which the destroy can be executed
     */
    function announceDestroyAgent(
        address _agentVault
    ) external
        returns (uint256 _destroyAllowedAt);

    /**
     * Delete all agent data, self destruct agent vault and send remaining collateral to the `_recipient`.
     * Procedure for destroying agent:
     * - exit available agents list
     * - wait until all assets are redeemed or perform self-close
     * - announce destroy (and wait the required time)
     * - call destroyAgent()
     * NOTE: may only be called by the agent vault owner.
     * NOTE: the remaining funds from the vault will be transferred to the provided recipient.
     * @param _agentVault address of the agent's vault to destroy
     * @param _recipient address that receives the remaining funds and possible vault balance
     */
    function destroyAgent(
        address _agentVault,
        address payable _recipient
    ) external;

    /**
     * When agent vault, collateral pool or collateral pool token factory is upgraded, new agent vaults
     * automatically get the new implementation from the factory. But the existing agent vaults must
     * be upgraded by their owners using this method.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault address of the agent's vault; both vault, its corresponding pool, and
     *  its pool token will be upgraded to the newest implementations
     */
    function upgradeAgentVaultAndPool(
        address _agentVault
    ) external;

    /**
     * Check if the collateral pool token has been used already by some vault.
     * @param _suffix the suffix to check
     */
    function isPoolTokenSuffixReserved(
        string memory _suffix
    ) external view
        returns (bool);

    /**
     * Due to the effect on the pool, all agent settings are timelocked.
     * This method announces a setting change. The change can be executed after the timelock expires.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault agent vault address
     * @param _name setting name, same as for `getAgentSetting`
     * @return _updateAllowedAt the timestamp at which the update can be executed
     */
    function announceAgentSettingUpdate(
        address _agentVault,
        string memory _name,
        uint256 _value
    ) external
        returns (uint256 _updateAllowedAt);

    /**
     * Due to the effect on the pool, all agent settings are timelocked.
     * This method executes a setting change after the timelock expires.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault agent vault address
     * @param _name setting name, same as for `getAgentSetting`
     */
    function executeAgentSettingUpdate(
        address _agentVault,
        string memory _name
    ) external;

    /**
     * The agent is going to withdraw `_valueNATWei` amount of collateral from the agent vault.
     * This has to be announced and the agent must then wait `withdrawalWaitMinSeconds` time.
     * After that time, the agent can call `withdrawCollateral(_vaultCollateralToken, _valueNATWei)`
     * on the agent vault.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault agent vault address
     * @param _valueNATWei the amount to be withdrawn
     * @return _withdrawalAllowedAt the timestamp when the withdrawal can be made
     */
    function announceVaultCollateralWithdrawal(
        address _agentVault,
        uint256 _valueNATWei
    ) external
        returns (uint256 _withdrawalAllowedAt);

    /**
     * Agent is going to withdraw `_valuePoolTokenWei` of pool tokens from the agent vault
     * and redeem them for NAT from the collateral pool.
     * This has to be announced and the agent must then wait `withdrawalWaitMinSeconds`.
     * After that time, the agent can call redeemCollateralPoolTokens(_valuePoolTokenWei) on agent vault.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault agent vault address
     * @param _valuePoolTokenWei the amount to be withdrawn
     * @return _redemptionAllowedAt the timestamp when the redemption can be made
     */
    function announceAgentPoolTokenRedemption(
        address _agentVault,
        uint256 _valuePoolTokenWei
    ) external
        returns (uint256 _redemptionAllowedAt);

    /**
     * When the agent tops up his underlying address, it has to be confirmed by calling this method,
     * which updates the underlying free balance value.
     * NOTE: may only be called by the agent vault owner.
     * @param _payment proof of the underlying payment; must include payment
     *      reference of the form `0x4642505266410011000...0<agents_vault_address>`
     * @param _agentVault agent vault address
     */
    function confirmTopupPayment(
        IPayment.Proof calldata _payment,
        address _agentVault
    ) external;

    /**
     * Announce withdrawal of underlying currency.
     * In the event UnderlyingWithdrawalAnnounced the agent receives payment reference, which must be
     * added to the payment, otherwise it can be challenged as illegal.
     * Until the announced withdrawal is performed and confirmed or canceled, no other withdrawal can be announced.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault agent vault address
     */
    function announceUnderlyingWithdrawal(
        address _agentVault
    ) external;

    /**
     * Agent must provide confirmation of performed underlying withdrawal, which updates free balance with used gas
     * and releases announcement so that a new one can be made.
     * If the agent doesn't call this method, anyone can call it after a time (`confirmationByOthersAfterSeconds`).
     * NOTE: may only be called by the owner of the agent vault
     *   except if enough time has passed without confirmation - then it can be called by anybody.
     * @param _payment proof of the underlying payment
     * @param _agentVault agent vault address
     */
    function confirmUnderlyingWithdrawal(
        IPayment.Proof calldata _payment,
        address _agentVault
    ) external;

    /**
     * Cancel ongoing withdrawal of underlying currency.
     * Needed in order to reset announcement timestamp, so that others cannot front-run the agent at
     * `confirmUnderlyingWithdrawal` call. This could happen if withdrawal would be performed more
     * than `confirmationByOthersAfterSeconds` seconds after announcement.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault agent vault address
     */
    function cancelUnderlyingWithdrawal(
        address _agentVault
    ) external;

    /**
     * Get (a part of) the list of all active (not destroyed) agents.
     * The list must be retrieved in parts since retrieving the whole list can consume too much gas for one block.
     * @param _start first index to return from the available agent's list
     * @param _end end index (one above last) to return from the available agent's list
     */
    function getAllAgents(uint256 _start, uint256 _end)
        external view
        returns (address[] memory _agents, uint256 _totalLength);

    /**
     * Return detailed info about an agent, typically needed by a minter.
     * @param _agentVault agent vault address
     * @return structure containing agent's minting fee (BIPS), min collateral ratio (BIPS),
     *      and current free collateral (lots)
     */
    function getAgentInfo(address _agentVault)
        external view
        returns (AgentInfo.Info memory);

    /**
     * Get agent's setting by name.
     * This allows reading individual settings.
     * @param _agentVault agent vault address
     * @param _name setting name, one of: `feeBIPS`, `poolFeeShareBIPS`, `redemptionPoolFeeShareBIPS`,
     *  `mintingVaultCollateralRatioBIPS`, `mintingPoolCollateralRatioBIPS`,`buyFAssetByAgentFactorBIPS`,
     *  `poolExitCollateralRatioBIPS`
     */
    function getAgentSetting(address _agentVault, string memory _name)
        external view
        returns (uint256);

    /**
     * Returns the collateral pool address of the agent identified by `_agentVault`.
     */
    function getCollateralPool(address _agentVault)
        external view
        returns (address);

    /**
     * Return the management address of the owner of the agent identified by `_agentVault`.
     */
    function getAgentVaultOwner(address _agentVault)
        external view
        returns (address _ownerManagementAddress);

    /**
     * Return vault collateral ERC20 token chosen by the agent identified by `_agentVault`.
     */
    function getAgentVaultCollateralToken(address _agentVault)
        external view
        returns (IERC20);

    /**
     * Return full vault collateral (free + locked) deposited in the vault `_agentVault`.
     */
    function getAgentFullVaultCollateral(address _agentVault)
        external view
        returns (uint256);

    /**
     * Return full pool NAT collateral (free + locked) deposited in the vault `_agentVault`.
     */
    function getAgentFullPoolCollateral(address _agentVault)
        external view
        returns (uint256);

    /**
     * Return the current liquidation factors and max liquidation amount of the agent
     * identified by `_agentVault`.
     */
    function getAgentLiquidationFactorsAndMaxAmount(address _agentVault)
        external view
        returns (
            uint256 liquidationPaymentFactorVaultBIPS,
            uint256 liquidationPaymentFactorPoolBIPS,
            uint256 maxLiquidationAmountUBA
        );

    /**
     * Return the minimum collateral ratio of the pool collateral owned by vault `_agentVault`.
     */
    function getAgentMinPoolCollateralRatioBIPS(address _agentVault)
        external view
        returns (uint256);

    /**
     * Return the minimum collateral ratio of the vault collateral owned by vault `_agentVault`.
     */
    function getAgentMinVaultCollateralRatioBIPS(address _agentVault)
        external view
        returns (uint256);

    /**
     * Add the agent to the list of publicly available agents.
     * Other agents can only self-mint.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault agent vault address
     */
    function makeAgentAvailable(
        address _agentVault
    ) external;

    /**
     * Announce exit from the publicly available agents list.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault agent vault address
     * @return _exitAllowedAt the timestamp when the agent can exit
     */
    function announceExitAvailableAgentList(
        address _agentVault
    ) external
        returns (uint256 _exitAllowedAt);

    /**
     * Exit the publicly available agents list.
     * NOTE: may only be called by the agent vault owner and after announcement.
     * @param _agentVault agent vault address
     */
    function exitAvailableAgentList(
        address _agentVault
    ) external;

    /**
     * Get (a part of) the list of available agents.
     * The list must be retrieved in parts since retrieving the whole list can consume too much gas for one block.
     * @param _start first index to return from the available agent's list
     * @param _end end index (one above last) to return from the available agent's list
     */
    function getAvailableAgentsList(uint256 _start, uint256 _end)
        external view
        returns (address[] memory _agents, uint256 _totalLength);

    /**
     * Get (a part of) the list of available agents with extra information about agents' fee, min collateral ratio
     * and available collateral (in lots).
     * The list must be retrieved in parts since retrieving the whole list can consume too much gas for one block.
     * NOTE: agent's available collateral can change anytime due to price changes, minting, or changes
     * in agent's min collateral ratio, so it is only to be used as an estimate.
     * @param _start first index to return from the available agent's list
     * @param _end end index (one above last) to return from the available agent's list
     */
    function getAvailableAgentsDetailedList(uint256 _start, uint256 _end)
        external view
        returns (AvailableAgentInfo.Data[] memory _agents, uint256 _totalLength);

    /**
     * A new agent vault was created.
     */
    event AgentVaultCreated(
        address indexed owner,
        address indexed agentVault,
        AgentVaultCreationData creationData);

    /**
     * Agent has announced destroy (close) of agent vault and will be able to
     * perform destroy after the timestamp `destroyAllowedAt`.
     */
    event AgentDestroyAnnounced(
        address indexed agentVault,
        uint256 destroyAllowedAt);

    /**
     * Agent has destroyed (closed) the agent vault.
     */
    event AgentDestroyed(
        address indexed agentVault);

    /**
     * Agent has announced a withdrawal of collateral and will be able to
     * withdraw the announced amount after timestamp `withdrawalAllowedAt`.
     * If withdrawal was canceled (announced with amount 0), amountWei and withdrawalAllowedAt are zero.
     */
    event VaultCollateralWithdrawalAnnounced(
        address indexed agentVault,
        uint256 amountWei,
        uint256 withdrawalAllowedAt);

    /**
     * Agent has announced a withdrawal of collateral and will be able to
     * redeem the announced amount of pool tokens after the timestamp `withdrawalAllowedAt`.
     * If withdrawal was canceled (announced with amount 0), amountWei and withdrawalAllowedAt are zero.
     */
    event PoolTokenRedemptionAnnounced(
        address indexed agentVault,
        uint256 amountWei,
        uint256 withdrawalAllowedAt);

    /**
     * Agent was added to the list of available agents and can accept collateral reservation requests.
     */
    event AgentAvailable(
        address indexed agentVault,
        uint256 feeBIPS,
        uint256 mintingVaultCollateralRatioBIPS,
        uint256 mintingPoolCollateralRatioBIPS,
        uint256 freeCollateralLots);

    /**
     * Agent exited from available agents list.
     * The agent can exit the available list after the timestamp `exitAllowedAt`.
     */
    event AvailableAgentExitAnnounced(
        address indexed agentVault,
        uint256 exitAllowedAt);

    /**
     * Agent exited from available agents list.
     */
    event AvailableAgentExited(
        address indexed agentVault);

    /**
     * Agent has initiated setting change (fee or some agent collateral ratio change).
     * The setting change can be executed after the timestamp `validAt`.
     */
    event AgentSettingChangeAnnounced(
        address indexed agentVault,
        string name,
        uint256 value,
        uint256 validAt);

    /**
     * Agent has executed setting change (fee or some agent collateral ratio change).
     */
    event AgentSettingChanged(
        address indexed agentVault,
        string name,
        uint256 value);

    /**
     * Agent or agent's collateral pool has changed token contract.
     */
    event AgentCollateralTypeChanged(
        address indexed agentVault,
        uint8 collateralClass,
        address token);

    /**
     * Part of the balance in the agent's underlying address is "free balance" that the agent can withdraw.
     * It is obtained from minting / redemption fees and self-closed fassets.
     * Some of this amount should be left for paying redemption (and withdrawal) gas fees,
     * and the rest can be withdrawn by the agent.
     * However, withdrawal has to be announced, otherwise it can be challenged as illegal payment.
     * Only one announcement can exist per agent - agent has to present payment proof for withdrawal
     * before starting a new one.
     */
    event UnderlyingWithdrawalAnnounced(
        address indexed agentVault,
        uint256 indexed announcementId,
        bytes32 paymentReference);

    /**
     * After announcing legal underlying withdrawal and creating transaction,
     * the agent must confirm the transaction. This frees the announcement so the agent can create another one.
     * If the agent doesn't confirm in time, anybody can confirm the transaction after several hours.
     * Failed payments must also be confirmed.
     */
    event UnderlyingWithdrawalConfirmed(
        address indexed agentVault,
        uint256 indexed announcementId,
        int256 spentUBA,
        bytes32 transactionHash);

    /**
     * After announcing legal underlying withdrawal agent can cancel ongoing withdrawal.
     * The reason for doing that would be in resetting announcement timestamp due to any problems with underlying
     * withdrawal - in order to prevent others to confirm withdrawal before agent and get some of his collateral.
     */
    event UnderlyingWithdrawalCancelled(
        address indexed agentVault,
        uint256 indexed announcementId);

    /**
     * Emitted when the agent tops up the underlying address balance.
     */
    event UnderlyingBalanceToppedUp(
        address indexed agentVault,
        bytes32 transactionHash,
        uint256 depositedUBA);

    /**
     * Emitted whenever the tracked underlying balance changes.
     */
    event UnderlyingBalanceChanged(
        address indexed agentVault,
        int256 underlyingBalanceUBA);
}
