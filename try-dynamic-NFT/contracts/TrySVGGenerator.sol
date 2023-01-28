pragma solidity  0.8.15;

import '@openzeppelin/contracts/utils/Base64.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

contract TrySVGGenerator {
    using Strings for uint8;
    using Strings for address;

    function constructTokenURI() public view returns (string memory) {
        string memory image = generateSVGImage();
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked('{"image": "', 'data:image/svg+xml;base64,', image, '"}')
                    )
                )
            )
        );
    }

    function generateSVGImage() public view returns (string memory) {
        return Base64.encode(bytes(
            string(
                abi.encodePacked(
                    '<svg viewBox="0 0 90 60" fill="none" role="img" xmlns="http://www.w3.org/2000/svg" width="540" height="360">',
                    _getSVGDefs(),
                    '<rect width="90" height="60" fill="url(#base-bg)" rx="6" />',
                    '<rect width="83" height="53" x="3.5" y="3.5" rx="5" stroke-width="0.5" stroke="white" />',
                    _getMainText(),
                    _getCircles(),
                    _getBorderTexts(),
                    '</svg>'
                )
            )
        ));
    }

    function _getSVGDefs() private view returns (bytes memory) {
        return abi.encodePacked(
            '<defs>',
            '<path id="text-path" d="M7 3h76a4 4 0 0 1 4 4v46a4 4 0 0 1 -4 4h-76a4 4 0 0 1 -4 -4v-46a4 4 0 0 1 4 -4" />',
            '<linearGradient id="base-bg" x1="0.15" x2="0.85" y1="0.4" y2="0.6">',
            '<stop offset="0%" stop-color="#1E263F" />',
            '<stop offset="50%" stop-color="#254ECF" />',
            '<stop offset="100%" stop-color="#1E263F" />',
            '</linearGradient>',
            '</defs>'
        );
    }

    function _getMainText() private view returns (bytes memory) {
        return abi.encodePacked(
            '<text text-anchor="middle" x="45" y="20" fill="white" font-size="6" font-weight="bold">',
                "Crypto Tours #1",
            '</text>'
        );
    }

    function _getCircles() private view returns (bytes memory) {
        return abi.encodePacked(
            '<g fill="white">',
            '<line x1="15" x2="75" y1="36" y2="36" stroke="#282828" stroke-width="2" />',
            '<line x1="15" x2="75" y1="36" y2="36" stroke="white" stroke-width="0.5" />',
            _getCircle(15, 36, 5),
            _getCircle(30, 36, 5),
            _getCircle(45, 36, 5),
            _getCircle(60, 36, 5),
            _getCircle(75, 36, 5),
            '</g>'
        );
    }

    function _getCircle(uint8 _cx, uint8 _cy, uint8 _r) private view returns (bytes memory) {
        return abi.encodePacked(
            '<circle cx="', _cx.toString(), '" cy="', _cy.toString(), '" r="', _r.toString(), '" />'   
        );
    }

    function _getBorderTexts() private view returns(bytes memory) {
        return abi.encodePacked(
            '<text text-rendering="optimizeSpeed">',
            _getTextPath("-100%"),
            _getTextPath("-0%"),
            _getTextPath("50%"),
            _getTextPath("-50%"),
            '</text>'
        );
    }

    function _getTextPath(string memory _startffset) private view returns (bytes memory) {
        return abi.encodePacked(
            '<textPath startOffset="', _startffset, '" fill="white" font-size="3" href="#text-path">',
            msg.sender.toHexString(),
            '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
            '</textPath>'
        );
    }
}