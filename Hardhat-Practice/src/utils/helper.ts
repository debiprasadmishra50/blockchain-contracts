import { BigNumber, ethers } from "ethers";

export const toWei = (value: number | BigNumber) => ethers.utils.parseEther(value.toString());

export const fromWei = (value: number | BigNumber) => ethers.utils.formatEther(value.toString());
