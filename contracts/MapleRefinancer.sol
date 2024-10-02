// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.7;

import {VennFirewallConsumer} from "@ironblocks/firewall-consumer/contracts/consumers/VennFirewallConsumer.sol";
import { IERC20 } from "../modules/erc20/contracts/interfaces/IERC20.sol";

import { IMapleLoanFeeManager } from "./interfaces/IMapleLoanFeeManager.sol";
import { IMapleRefinancer }     from "./interfaces/IMapleRefinancer.sol";

import { MapleLoanStorage } from "./MapleLoanStorage.sol";

/*

    ███╗   ███╗ █████╗ ██████╗ ██╗     ███████╗    ██████╗ ███████╗███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗██████╗
    ████╗ ████║██╔══██╗██╔══██╗██║     ██╔════╝    ██╔══██╗██╔════╝██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗
    ██╔████╔██║███████║██████╔╝██║     █████╗      ██████╔╝█████╗  █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  ██████╔╝
    ██║╚██╔╝██║██╔══██║██╔═══╝ ██║     ██╔══╝      ██╔══██╗██╔══╝  ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  ██╔══██╗
    ██║ ╚═╝ ██║██║  ██║██║     ███████╗███████╗    ██║  ██║███████╗██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗██║  ██║
    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝  ╚═╝

*/

/// @title MapleRefinancer uses storage from a MapleLoan defined by MapleLoanStorage.
contract MapleRefinancer is VennFirewallConsumer, IMapleRefinancer, MapleLoanStorage {

    function increasePrincipal(uint256 amount_) external override firewallProtected {
        // Cannot under-fund the principal increase, but over-funding results in additional funds left unaccounted for.
        require(_getUnaccountedAmount(_fundsAsset) >= amount_, "R:IP:INSUFFICIENT_AMOUNT");

        _principal          += amount_;
        _principalRequested += amount_;
        _drawableFunds      += amount_;

        emit PrincipalIncreased(amount_);
    }

    function setClosingRate(uint256 closingRate_) external override firewallProtected {
        emit ClosingRateSet(_closingRate = closingRate_);
    }

    function setCollateralRequired(uint256 collateralRequired_) external override firewallProtected {
        emit CollateralRequiredSet(_collateralRequired = collateralRequired_);
    }

    function setEndingPrincipal(uint256 endingPrincipal_) external override firewallProtected {
        require(endingPrincipal_ <= _principal, "R:SEP:ABOVE_CURRENT_PRINCIPAL");
        emit EndingPrincipalSet(_endingPrincipal = endingPrincipal_);
    }

    function setGracePeriod(uint256 gracePeriod_) external override firewallProtected {
        emit GracePeriodSet(_gracePeriod = gracePeriod_);
    }

    function setInterestRate(uint256 interestRate_) external override firewallProtected {
        emit InterestRateSet(_interestRate = interestRate_);
    }

    function setLateFeeRate(uint256 lateFeeRate_) external override firewallProtected {
        emit LateFeeRateSet(_lateFeeRate = lateFeeRate_);
    }

    function setLateInterestPremiumRate(uint256 lateInterestPremiumRate_) external override firewallProtected {
        emit LateInterestPremiumRateSet(_lateInterestPremiumRate = lateInterestPremiumRate_);
    }

    function setPaymentInterval(uint256 paymentInterval_) external override firewallProtected {
        require(paymentInterval_ != 0, "R:SPI:ZERO_AMOUNT");

        emit PaymentIntervalSet(_paymentInterval = paymentInterval_);
    }

    function setPaymentsRemaining(uint256 paymentsRemaining_) external override firewallProtected {
        require(paymentsRemaining_ != 0, "R:SPR:ZERO_AMOUNT");

        emit PaymentsRemainingSet(_paymentsRemaining = paymentsRemaining_);
    }

    function updateDelegateFeeTerms(uint256 delegateOriginationFee_, uint256 delegateServiceFee_) external override firewallProtected {
        IMapleLoanFeeManager(_feeManager).updateDelegateFeeTerms(delegateOriginationFee_, delegateServiceFee_);
    }

    /// @dev Returns the amount of an `asset_` that this contract owns, which is not currently accounted for by its state variables.
    function _getUnaccountedAmount(address asset_) internal view returns (uint256 unaccountedAmount_) {
        return IERC20(asset_).balanceOf(address(this))
            - (asset_ == _collateralAsset ? _collateral    : uint256(0))   // `_collateral` is `_collateralAsset` accounted for.
            - (asset_ == _fundsAsset      ? _drawableFunds : uint256(0));  // `_drawableFunds` are `_fundsAsset` accounted for.
    }

}
