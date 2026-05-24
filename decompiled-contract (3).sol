contract DECOMPILED {

    function pauseBnft() external nonReentrant {
        _pause();
    }

    function depositWstETH() external payable {
        if (msg.sender != address(WSTETH)) {
            revert();
        }
        WSTETH.deposit{value: msg.value}();
    }

    function depositWstETH(
        address _receiver,
        bytes calldata _signature,
        uint256 _amount
    ) external payable nonReentrant {
        require(_signature.length == 32, "DD0");
        uint256 _amountWstETH = uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1))));
        require(_amountWstETH == _signature, "DD1");
        uint256 _amountWstETHReceived = IERC20(wstETH).balanceOf(address(this));
        IERC20(wstETH).safeIncreaseAllowance(_receiver, _amount);
        IWstETH(_receiver).deposit(_signature, _amount);
        wstETHReceived = _amountWstETHReceived;
    }

    function destroy(uint256 amount) external {
        _requireIsInitialized();

        if (amount > 0) {
            IERC20(asset).approve(address(erc20Router), amount);
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "DES");
        }

        selfdestruct(msg.sender);
    }

    function updateReward(address _token, bytes32[] calldata _merkleProof, uint256 _amount) external {
        _updateReward();
        require(_merkleProof[0] == bytes32(0), "DD0");
        require(_merkleProof[1] == keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1))), "DD1");
        IERC20(_token).mint(_msgSender(), _amount);
        _updateRewardPerToken(_amount);
    }

    function pancakeV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external override {
        _swapCallback(amount0Delta, amount1Delta, data, true);
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external override {
        _uniswapV3SwapCallback(amount0Delta, amount1Delta, data, false);
    }

    function delegate(address delegatee) external payable {
        _delegate(delegatee);
    }

}
