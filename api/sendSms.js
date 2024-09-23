import fetch from 'node-fetch';

export default async function handler(req, res) {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight (OPTIONS) request
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method === 'POST') {
    const { phoneNumber, message } = req.body;

    const hubtelUrl = 'https://sms.hubtel.com/v1/messages/send';

    const headers = {
      'Authorization': `Basic ${Buffer.from(`${process.env.CLIENT_ID}:${process.env.CLIENT_SECRET}`).toString('base64')}`,
      'Content-Type': 'application/json',
    };

    const body = JSON.stringify({
      From: process.env.SENDER,
      To: phoneNumber,
      Content: message,
      RegisteredDelivery: true,
    });

    try {
      const response = await fetch(hubtelUrl, {
        method: 'GET',  // Hubtel uses GET for sending SMS
        headers: headers,
        body: body,
      });

      // Check if the response is OK (status 200 or 201)
      if (response.ok) {
        const data = await response.json();
        res.status(200).json({ success: true, message: 'SMS sent successfully', data });
      } else {
        const errorData = await response.json();
        res.status(response.status).json({ success: false, message: 'Failed to send SMS', data: errorData });
      }
    } catch (error) {
      res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
  } else {
    res.status(405).json({ message: 'Only POST requests are allowed' });
  }
}
