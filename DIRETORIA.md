<!DOCTYPE html>
```
<html>
<head>
    <title>Github README Button</title>
    <style>
        /* Button styling */
        .button {
            display: inline-block;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            background-color: #0366d6;
            color: #fff;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            position: relative;
            transition: transform 0.3s ease;
        }
        
        .button:active {
            transform: translateY(2px);
        }
        
        .button:hover .bitcoin-symbol {
            transform: rotateY(180deg);
        }
        
        /* Bitcoin symbol styling */
        .bitcoin-symbol {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 24px;
            transition: transform 0.3s ease;
        }
        
        /* QR code styling */
        .qrcode {
            display: none;
            position: absolute;
            top: 100%;
            left: 50%;
            transform: translateX(-50%);
            background-color: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 5px rgba(0, 0, 0, 0.3);
        }
        
        .qrcode img {
            max-width: 200px;
        }
    </style>
</head>
<body>
    <button class="button" onclick="toggleQRCode()">
        <span class="bitcoin-symbol">₿</span>
    </button>

    <div class="qrcode" id="qrcode">
        <!-- QR code image will be inserted here -->
    </div>

    <script>
        function toggleQRCode() {
            var qrcode = document.getElementById('qrcode');
            qrcode.style.display = (qrcode.style.display === 'none') ? 'block' : 'none';
        }
    </script>
</body>
</html>
```
