import { Context } from "aws-lambda";

export type Handler<TEvent = any, TResult = any> = (event: TEvent, context: Context) => Promise<TResult>;

export type Text = { 
  label: string | undefined,
  text: string 
}

export type Payload = {
  headers: Array<Text>,
  data: Array<Text> ,
 
}