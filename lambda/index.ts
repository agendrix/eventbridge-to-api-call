import { Handler } from "aws-lambda";
import axios from 'axios';
import { Payload, Text } from "./types";
import { error } from "console";

const handler: Handler = async (payload: Payload) => {
  const apiKey = process.env.API_Key;
  const apiUrl = process.env.API_URL;
  const { headers, data } = payload;

  try {
    if (!apiUrl)
    {
        throw error;
    }
    // Make the HTTP request using Axios
    const response = await axios.post(apiUrl, data, {
        headers: headers,
    });

    if (response.status === 200) {
        console.log('Alert sent to API successfully');
    } else {
        console.error(`Failed to send alert to API. Status code: ${response.status}, Response: ${response.data}`);
    }
  } catch (error) {
      console.error('Error sending alert to API:', error.message);
  }


};

exports.handler = handler;