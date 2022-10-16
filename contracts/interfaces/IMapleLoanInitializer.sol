// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { IMapleLoanEvents } from "./IMapleLoanEvents.sol";

interface IMapleLoanInitializer is IMapleLoanEvents {

    /**
     *  @dev   Encodes the initialization arguments for a MapleLoan.
     *  @param borrower_    The address of the borrower.
     *  @param feeManager_  The address of the entity responsible for calculating fees
     *  @param assets_      Array of asset addresses.
     *                       [0]: collateralAsset,
     *                       [1]: fundsAsset
     *  @param termDetails_ Array of loan parameters:
     *                       [0]: gracePeriod,
     *                       [1]: paymentInterval,
     *                       [2]: payments
     *  @param amounts_     Requested amounts:
     *                       [0]: collateralRequired,
     *                       [1]: principalRequested,
     *                       [2]: endingPrincipal
     *  @param rates_       Rates parameters:
     *                       [0]: interestRate,
     *                       [1]: closingFeeRate,
     *                       [2]: lateFeeRate,
     *                       [3]: lateInterestPremium,
     *  @param fees_        Array of fees:
     *                       [0]: delegateOriginationFee,
     *                       [1]: delegateServiceFee
     */
    function encodeArguments(
        address borrower_,
        address feeManager_,
        address[2] memory assets_,
        uint256[3] memory termDetails_,
        uint256[3] memory amounts_,
        uint256[4] memory rates_,
        uint256[2] memory fees_
    ) external pure returns (bytes memory encodedArguments_);

    /**
     *  @dev   Decodes the initialization arguments for a MapleLoan.
     *  @return borrower_    The address of the borrower.
     *  @return feeManager_  The address of the entity responsible for calculating fees
     *  @return assets_      Array of asset addresses.
     *                        [0]: collateralAsset,
     *                        [1]: fundsAsset
     *  @return termDetails_ Array of loan parameters:
     *                        [0]: gracePeriod,
     *                        [1]: paymentInterval,
     *                        [2]: payments
     *  @return amounts_     Requested amounts:
     *                        [0]: collateralRequired,
     *                        [1]: principalRequested,
     *                        [2]: endingPrincipal
     *  @return rates_       Rates parameters:
     *                        [0]: interestRate,
     *                        [1]: closingFeeRate,
     *                        [2]: lateFeeRate,
     *                        [3]: lateInterestPremium,
     *  @return fees_        Array of fees:
     *                        [0]: delegateOriginationFee,
     *                        [1]: delegateServiceFee
     */
    function decodeArguments(bytes calldata encodedArguments_) external pure
        returns (
            address borrower_,
            address feeManager_,
            address[2] memory assets_,
            uint256[3] memory termDetails_,
            uint256[3] memory amounts_,
            uint256[4] memory rates_,
            uint256[2] memory fees_
        );

}
