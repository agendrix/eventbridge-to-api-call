import { Handler } from "aws-lambda";
import axios from 'axios';
import { Payload } from "./types";
import { error } from "console";

const handler: Handler = async (payload: Payload) => {
  const apiKey = process.env.API_KEY;
  const apiUrl = process.env.API_URL;
  const { headers, data } = payload;
  headers.Authorization = headers.Authorization + apiKey;
  try {
    if (!apiUrl)
    {
        throw new error('API URL is missing');
    }

    const response = await axios.post(apiUrl, JSON.stringify(data), {
        headers: headers,
    });

    if (response.status === 200 || response.status === 202) {
        console.log(`Alert sent to API successfully with status ${response.status}`);
    } else {
        console.error(`Failed to send alert to API. Status code: ${response.status}, Response: ${response.data}`);
    }
  } catch (error) {
      console.error('Error sending alert to API:', error.message);
  }


};

exports.handler = handler;