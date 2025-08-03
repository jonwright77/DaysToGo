# News API Setup Guide

The DaysToGo app uses NewsAPI.org to fetch news headlines from specific dates. Follow these steps to configure your API key.

## Step 1: Get a News API Key

1. Go to [https://newsapi.org/](https://newsapi.org/)
2. Click "Get API Key" and sign up for a free account
3. Copy your API key (it will look like: `abc123def456ghi789jkl012mno345pq`)

## Step 2: Configure the API Key

You have two options:

### Option A: Using Config.plist (Recommended for Development)

1. Copy `Config.plist.template` to `Config.plist`:
   ```bash
   cd DaysToGo
   cp Config.plist.template Config.plist
   ```

2. Open `Config.plist` and replace `YOUR_NEWS_API_KEY_HERE` with your actual API key

3. **Important**: `Config.plist` is in `.gitignore` to keep your key secure

### Option B: Using UserDefaults (Recommended for Testing)

You can set the API key at runtime using UserDefaults:

```swift
UserDefaults.standard.set("YOUR_API_KEY", forKey: "NewsAPIKey")
```

## Step 3: Build and Run

That's it! The app will now fetch news headlines from the reflection dates.

## Troubleshooting

### "News API key not configured" error
- Make sure you've created `Config.plist` from the template
- Verify the key name is exactly `NewsAPIKey`
- Check that your API key is valid

### "API rate limit exceeded" error
- Free tier: 100 requests/day
- Consider caching headlines or upgrading to paid tier

### No headlines showing
- Check the date - NewsAPI only has data from the last ~30 days for free tier
- Verify internet connection
- Check Xcode console for error logs

## API Limits

**Free Tier:**
- 100 requests/day
- Historical data: Last 30 days only
- No commercial use

**Paid Tier:**
- From $449/month
- Unlimited historical data
- Commercial use allowed

For personal use, the free tier should be sufficient.

## Apple Intelligence Enhancement

On iOS 18+ devices with Apple Intelligence, headlines will automatically be enhanced with AI-generated summaries. No configuration needed - it works automatically!

On older devices, headlines will display without summaries.
